#! /bin/bash
# A bash file for adding mirrors to OpenRA mirror lists
TargetMirrors="http://ftp.ubuntu-tw.org/mirror/anthonos/openra/ \
http://ftp.ubuntu-tw.org/mirror/anthonos/openra/ \
http://mirrors.ustc.edu.cn/anthon/openra/ \
http://mirrors.yun-idc.com/anthon/openra/ \
http://mirrors.oss.org.cn/anthon/openra/ \
http://mirrors.hust.edu.cn/anthon/openra/ \
http://mirror.pcbeta.com/anthonos/openra/ \
http://mirror.oss.maxcdn.com/anthonos/openra/ " #mirror.anthonos.org
#FileNames="freetype-zlib.zip .zip"


genmirror(){
	FIRST=1
	for i in $TargetMirrors
	do
		[ "$FIRST" = "1" ] && FIRST=0
		printf "$i"
		[ "$FIRST" != "1" ] && printf "$FileName\n"
	done
}

#for FileName in $FileNames
#do
#	genmirror >> $FileName.txt
#done

FileName="cg-win32.zip" genmirror >> ./releases/windows/cg-mirrors.txt
#FileName="d2k-103-packages.zip" genmirror >> ./packages/d2k-103-mirrors.txt
FileName="d2k-complete-packages.zip" genmirror >> ./packages/d2k-complete-mirrors.txt
FileName="ts-packages.zip" genmirror >> ./packages/ts-mirrors.txt
FileName="d2k-packages.zip" genmirror >> ./packages/d2k-mirrors.txt
FileName="freetype-zlib.zip" genmirror >> ./releases/windows/freetype-mirrors.txt
FileName="oalinst.zip" genmirror >> ./releases/windows/openal-mirrors.txt
FileName="SDL-1.2.14-win32.zip" genmirror >> ./releases/windows/sdl-mirrors.txt
#Well, where can we place music mirrors?
#FileName="" genmirror >>
#FileName="" genmirror >>
#FileName="" genmirror >>

