tell application "Finder"
	activate
	set s to path to me
	display dialog (localized string "A previous version has been found. To continue, this version will be removed. Would you like to proceed?" in bundle s) buttons {localized string "Yes" in bundle s, localized string "No" in bundle s} default button 1
	--with icon caution
	if the button returned of the result is (localized string "No" in bundle s) then
		continue quit
	end if
	
	
end tell

