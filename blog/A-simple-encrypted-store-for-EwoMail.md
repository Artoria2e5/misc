A simple encrypted store for EwoMail
====================================

EwoMail is a LNMP + Dovecot + Postfix package for CentOS 7 and 8.  Now you probably think
"man, this sucks!", and yes it does, but it isn't our point here.  I have started with a
CentOS 8 system, installed EwoMail, and then upgraded things piecewise to Stream 9.

Today we talk about the cool stuff.  The spy stuff.  We put everything in an encrypted bin,
the key for which we can burn (relatively more easily) than the actual thing.

Properties we want for the system is:

* Encrypted, of course.
* A separate, on-disk key that is relatively easily erased.
* A store that grows and (optimally) shrinks with the data.
* Snapshots. Users do things they regret later on all the time.

Now the third point is a bit tricky.  We can't just use a LUKS image, because that
doesn't shrink.  So we use a qcow2 image, as in the thing from qemu.  Of course
qcow2s are not exactly designed to be used on-host, but `qemu-nbd` is a thing.

We also compromise a bit on the encryption:  LUKS is a bother to set up, so we just
use qemu's built-in encryption.  It's not as secure, but it's good enough for our
purposes.  We aren't changing the key anytime soon, and I doubt zstd is going to make
chosen plaintext attacks easy.

Step 1: Create the image
------------------------

```sh
mkdir /store
cd /store
head -c 16 /dev/urandom > key
qemu-img create --object secret,id=sec,data=$(<key) -o encryption=on,cluster_size=2M,preallocation=metadata,lazy_refcounts,encrypt.key-secret=sec -f qcow2 qcow2 40G
```

Step 2: Mount the image for a first spin
----------------------------------------

```sh
cat > nbd-up.sh <<EOF
#!/bin/sh
qemu-nbd --object secret,id=sec,data=$(<key) -c /dev/nbd1 --image-opts driver=qcow2,file.driver=file,file.filename=/store/qcow2,encrypt.format=aes,encrypt.key-secret=sec
EOF
chmod +x nbd-up.sh

./nbd-up.sh
```

Obviously we'd want to partition and format the thing. Under `gdisk /dev/nbd1`:

```
n
1
w
```

Then make a btrfs filesystem and mount it:

```sh
mkfs.btrfs -O bgt /dev/nbd1p1
mkdir mnt
mount /dev/nbd1p1 mnt
```

We promised snapshotting.  Now we can either do it via qcow2 or btrfs, but I'm more inclined to do it via btrfs.  So let's do a subvolume.

```sh
btrfs subvolume create mnt/@ewomail
```

Now we're ready to use it.  We can snapshot it with `btrfs subvolume snapshot mnt/@ewomail mnt/@ewomail-snap`.

We do want to move all the ewomail stuff in:

```sh
systemctl stop dovecot postfix nginx php-fpm mysqld amavisd
cp -a /ewomail/* mnt/@ewomail
```

Step 3: Unmount the image
-------------------------

```sh
umount mnt
qemu-nbd -d /dev/nbd1
```

Step 4: Systemd
----------------

We want to integrate all this into systemd, so that it's mounted before anything that depends on `/ewomail` starts.

```ini
# /etc/systemd/system/ewostore.service
[Unit]
Description=Ewostore NBD connection
User=root

[Service]
Type=forking
ExecStartPre=-/usr/bin/qemu-nbd -d /dev/nbd0
ExecStartPre=/usr/sbin/modprobe nbd
ExecStart=sh -c "/usr/bin/qemu-nbd --object secret,id=sec,data=$(</store/key) -c /dev/nbd0 --image-opts driver=qcow2,file.driver=file,file.filename=/store/qcow2,encrypt.format=aes,encrypt.key-secret=sec --pid-file=/run/qemu-nbd.pid"
ExecStop=/usr/bin/qemu-nbd -d /dev/nbd0
Restart=no
PIDFile=/run/qemu-nbd.pid

[Install]
WantedBy=ewostore-mnt.mount
RequiredBy=ewostore-mnt.mount
```

Note the very important `sh -c`: systemd does not understand `$(<filename)` expansions.

A mount point for the real thing for snapshotting:

```ini
# /etc/systemd/system/store-mnt.mount
[Unit]
Description=/ewostore/mnt mount
After=ewostore.service
Requires=ewostore.service
User=root

[Mount]
What=/dev/nbd0p1
Where=/store/mnt
Type=btrfs
Options=defaults,lazytime,compress=zstd
TimeoutSec=2
```

And a bind to the old place (note the `Before`):

```ini
[Unit]
Description=/ewomail bind mount
After=ewostore-mnt.mount
Requires=ewostore-mnt.mount
User=root
Before=clamd@amavisd.service amavisd.service dovecot.service nginx.service postfix.service mysqld.service php-fpm.service php-fpm83.service

[Mount]
What=/ewostore/mnt/@ewomail
Where=/ewomail
Type=none
Options=bind
TimeoutSec=2

[Install]
WantedBy=dovecot-init.service
RequiredBy=clamd@amavisd.service amavisd.service dovecot.service nginx.service postfix.service mysqld.service php-fpm.service php-fpm83.service
```

And we want to snapshot it. I cowardly chose to do it via crontab:

```crontab
0 3 * * * jdupes2 -L -r /ewomail/mail/Attachments
0 4 * * 6 btrfs subvolume snapshot /ewostore/mnt/@ewomail{,$(date +%s)}
```

Note the bit of `jdupes`: I have previously changed dovecot to use `sdbox` so that attachments are stored in a separate directory. Big files get forwarded around a lot, so we want to deduplicate them. For how to do that, `doveadm sync` is your friend. Of course, dovecot sis is a bit of a pain, so I'd rather compile my own `jdupes` and use that.

We'd want to enable all of them, of course:

```sh
systemctl enable ewostore ewomail.mount store-mnt.mount
```

And turn on what got turned off:

```sh
systemctl start dovecot postfix nginx php-fpm mysqld amavisd
```

Step 5: Profit
---------------

Now we have a system that is encrypted, easily snapshot-able, and can be moved around. We can also easily erase the key with `shred`. With some prayers (we have an un-trimmable VHD on a SSD, after all), we can all pretend that the key is erased and the data is gone.
