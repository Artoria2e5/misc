#! /bin/bash
# Uses zenity and the undocumented gettext on bash.
TEXTDOMAIN="TI_NS"
TEXTDOMAINDIR="/usr/share/locale"
APPNAME="TI_foobar"
_LOCALIZED=$"Another application is open.
Please close it to continue.
Click on Cancel to exit."

             # So we don't see grep $APPNAME in ps.
while (ps ax | grep -v grep | grep $APPNAME ); do 
zenity --question --default-cancel \
--title=$"File In Use - TI Nspire" --text="$_LOCALIZED" || break
done
