#!/bin/bash
# Script for spinning up chrony on Debian and Ubuntu VMs
# how are we doing? https://www.ntppool.org/a/a2e5
apt install -y chrony

cat <<EOF > /etc/modules-load.d/ptp.conf
ptp_kvm
EOF
modprobe ptp_kvm

sed -e 's/^pool/#pool/g' -i /etc/chrony/chrony.conf
cat <<EOF >> /etc/chrony/chrony.conf
allow all
dumpdir /var/log/chrony
log measurements statistics tracking

hwtimestamp *
refclock PHC /dev/ptp0 poll 3 dpoll -2 stratum 2
EOF

cat <<EOF >> /etc/chrony/sources.d/europe.sources
# NL
server 2a00:d78:0:712:94:198:159:10 iburst xleave
server 193.79.237.14 iburst xleave
# DE
server 192.53.103.104 iburst xleave
server 44.225.94.177 iburst xleave
EOF

cat <<EOF >> /etc/chrony/sources.d/north-america.sources
server 216.218.192.202 iburst xleave
server 216.218.254.202 iburst xleave
server 204.152.184.72 iburst xleave
server 192.12.19.20 iburst xleave
server 164.67.62.194 iburst xleave
server 128.138.188.172 iburst xleave
server 63.145.169.3 iburst xleave
server ntpsec.anastrophe.com iburst xleave
EOF

cat <<EOF >> /etc/chrony/sources.d/east-asia.sources
# HK
server 118.143.17.83 iburst xleave
server 223.255.185.2 iburst xleave
server 118.143.17.82 iburst xleave
server 2403:2c80::1:20 iburst xleave
# CN
server 47.243.51.23 iburst xleave
# ID
server 2001:df0:9a:12::1 iburst xleave
# JP
server 2001:2f8:29:100::fff3 iburst xleave
# SG
server 2405:fc00::123 iburst xleave
EOF

cat <<EOF >> /etc/chrony/sources.d/pool.sources
peer 2400:8a20:121:4::26 iburst xleave
peer 2406:4440:0:105::2e:a iburst xleave
peer 2602:feda:30:ae86:20d:1fff:fe3b:a061 iburst xleave

peer 2.56.247.37 iburst xleave
peer 37.114.35.161 iburst xleave
EOF

chronyc dump
systemctl restart chrony

cd /root
curl -fsSL https://bun.sh/install | bash
echo 'PATH+=:/root/.bun/bin' >> /etc/profile.d/99-bun.sh
source /etc/profile.d/99-bun.sh
ln -s bun /root/.bun/bin/node
bun install -g svgo

git clone https://github.com/Artoria2e5/chrony-graph
pushd chrony-graph
cp -a runX run1
cp -a bin/copy-to-website{.example,}
sed -e 's@~/my.www.dir/html/graphs/@/var/www/html@g' -i bin/copy-to-website
cp -a titles{.example,}
echo '0 * * * * /root/chrony-graph/run1/run-cron' > /var/spool/cron/crontabs/root
popd

apt install -y bc gnuplot-nox libdatetime-perl rsync nginx
sed -e 's@# gzip@gzip@g' \
    -e 's@gzip_types@gzip_types image/svg+xml@g' \
    -e 's@gzip on;@gzip on;\n    gzip_static on;@g' \
    -i /etc/nginx/nginx.conf
systemctl enable nginx
systemctl restart nginx

chronyc dump
/root/chrony-graph/run1/run-cron

IPTABLES='*raw
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A PREROUTING -p udp -m udp --dport 123 -j NOTRACK
-A PREROUTING -p udp -m udp --dport 11123 -j NOTRACK
-A PREROUTING -p udp -m udp --dport 123 -m hashlimit --hashlimit-above 8/sec --hashlimit-burst 16 --hashlimit-mode srcip --hashlimit-name ntp1 --hashlimit-htable-max 4096 --hashlimit-htable-expire 8000 --hashlimit-srcmask @srcmark@ -j DROP
-A PREROUTING -p udp -m udp --dport 123 -m statistic --mode random --probability 0.06250000000 -j ACCEPT
-A PREROUTING -p udp -m udp --dport 123 -m hashlimit --hashlimit-above 8/min --hashlimit-burst 8 --hashlimit-mode srcip --hashlimit-name ntp --hashlimit-htable-max 131072 --hashlimit-htable-expire 64000 --hashlimit-srcmask @srcmark@ -j DROP
-A OUTPUT -p udp -m udp --sport 123 -j NOTRACK
-A OUTPUT -p udp -m udp --sport 11123 -j NOTRACK
COMMIT'
IPTABLES4=${IPTABLES//@srcmark@/28}
IPTABLES6=${IPTABLES//@srcmark@/60}

apt install -y ufw
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 123/udp
echo "$IPTABLES4" >> /etc/ufw/before.rules
echo "$IPTABLES6" >> /etc/ufw/before6.rules
ufw --force enable

ip addr show eth0
