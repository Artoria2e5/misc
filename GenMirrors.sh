#! /bin/bash
# A bash file for adding mirrors to OpenRA mirror lists (or generate?)
TargetMirrors="http://ftp.ubuntu-tw.org/mirror/anthonos/openra/ \
http://ftp.ubuntu-tw.org/mirror/anthonos/openra/ \
http://mirrors.ustc.edu.cn/anthon/openra/ \
http://mirrors.yun-idc.com/anthon/openra/ \
http://mirrors.oss.org.cn/anthon/openra/ \
http://mirrors.hust.edu.cn/anthon/openra/ \
http://mirror.pcbeta.com/anthonos/openra/ \
http://mirror.oss.maxcdn.com/anthonos/openra/ " #mirror.anthonos.org
FileNames="freetype-zlib.zip ra-packages.zip"


genmirror(){
	FIRST=1
	for i in $TargetMirrors
	do
		[ "$FIRST" = "1" ] && FIRST=0
		printf "$i"
		[ "$FIRST" != "1" ] && printf "$FileName\n"
	done
}

for FileName in $FileNames
do
	genmirror >> $FileName.txt
done
