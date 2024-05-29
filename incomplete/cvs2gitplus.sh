#!/bin/bash
# http://www.embecosm.com/appnotes/ean11/ean11-howto-cvs-git-1.0.html , Simon Cook, Embecosm
# This software is free software; It is released under the CC-BY 2.0 UK License.
# Copyright (c) 2014 Arthur Wang <arthur200126@gmail.com>

read -p "Enter destination directory for module specific CVS repo:" DESTDIR
read -p "Enter destination directory for module specific Git repo:" GITDIR
read -p "Enter URL to push the module specific Git repository to:" REPOURL
read -p "Enter source directory for storing initial local copy of CVS repo:" SRCDIR

while true; do
read -p "Are you using a remote repo?(y/n)" -n 1 remote
if [ "$remote" == "y" ]
then cloneremote; break
else if [ "$remote" == "n" ]; then break; fi
fi
done

cloneremote(){
read -p "Please Enter 
