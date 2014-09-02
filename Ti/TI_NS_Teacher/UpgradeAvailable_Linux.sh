#! /bin/bash
# Uses zenity and the undocumented gettext on bash.
TEXTDOMAIN="TI_NS"
TEXTDOMAINDIR="/usr/share/locale"
_LOCALIZED="A Previous version has been found. To continue, this version will be removed.
Would you like to proceed?"

zenity --question --default-cancel --title=$"Upgrade Available - TI Nspire" --icon-name=caution --text="$_LOCALIZED"
