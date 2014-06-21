#!/bin/bash
# Strip-deb: A Shell script used to strip everything from a deb, and then pack it back.

fileenum(){
	for i in `find .` # Well, be a bit BSD-find-friendly...
	do
		[ ! -e $i ] && continue
		eval `echo $1 | sed "s@{}@$i@g"`
	done
}
elfstrip(){
	( file $1 | grep '\: ELF' > /dev/null )	&& (( echo "$i" | grep "/bin/" 1>/dev/null 2>&1 || echo "$i" | grep "/sbin" 1>/dev/null 2>&1 ) && strip --strip-all $1 2> /dev/null || strip --strip-debug $1 2> /dev/null ) || return 0 
}
fltr_elffltr(){
        for i in usr/lib lib bin usr/bin opt/*/lib opt/*/bin
        do
                [ -d $i ] || continue
                pushd $i >/dev/null
                fileenum "elfstrip {}"
                popd >/dev/null
        done
}

PKGDIR="/tmp/`date`"

dpkg-deb -r $1 $PKGDIR

pushd $PKGDIR
fltr_elffltr

# Use du to change the total size

# Well use sed to delete it first

echo "Installed-Size: `du -s abdist | cut -f 1`" >> DEBIAN/control

popd
dpkg-deb -Zxz -z9 -Sextreme -b $PKGDIR $1.deb.stripped
