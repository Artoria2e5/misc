tell application "Finder"
	activate
	set command to "ps ax | grep -v grep | grep JavaApplicationStub; exit 0"
	set the_result to do shell script command
	
	repeat while the_result is not equal to ""
		set SystemLanguage to do shell script "defaults read .GlobalPreferences AppleLanguages | tr -d [:space:] | cut -c2-3"

		(*
		if SystemLanguage is "es" then
			display dialog ("Hay otra aplicación abierta, ciérrela para continuar. Pulse Salir para  cancelar.") buttons {"Salir", "Reintentar"} default button 2 with icon caution
			if the button returned of the result is ("Salir") then
				continue quit
			end if
		else if SystemLanguage is "it" then
			display dialog ("Un'altra applicazione risulta aperta, chiuderla per continuare. Fare clic su uscire  per Annulla..") buttons {"Esci", "Ritenta"} default button 2 with icon caution
			if the button returned of the result is ("Esci") then
				continue quit
			end if
		else if SystemLanguage is "da" then
			display dialog ("En anden applikation er åbn. Luk denne og fortsæt.  Klik på Afslut for at Annuller.") buttons {"Afslut", "Forsøgigen"} default button 2 with icon caution
			if the button returned of the result is ("Afslut") then
				continue quit
			end if
		else if SystemLanguage is "de" then
			display dialog ("Eine weitere Applikation ist genet. Schliedfen Sie sie, um fortzufahren. Klicken Sie zum Beenden auf Abbrechenc.") buttons {"Verlassen", "Erneut versuchen"} default button 2 with icon caution
			if the button returned of the result is ("Verlassen") then
				continue quit
			end if
		else if SystemLanguage is "fi" then
			display dialog ("Toinen sovellus on kynniss. Sulje se, ennen kuin jatkat. Poistu napsauttamalla Peruuta.") buttons {"Poistu", "Yrite uudelleen"} default button 2 with icon caution
			if the button returned of the result is ("Poistu") then
				continue quit
			end if
		else if SystemLanguage is "fr" then
			display dialog ("Une autre application est ouverte. Veuillez la fermer pour continuer. Cliquez sur quitter pour Annuler ce menu.") buttons {"Quitter", "Reessayer"} default button 2 with icon caution
			if the button returned of the result is ("Quitter") then
				continue quit
			end if
		else if SystemLanguage is "nl" then
			display dialog ("Er is een andere toepassing geopend, sluit deze om verder te gaan. Klik op Annuleren om af te sluiten.") buttons {"Annuleren", "Opnieuw proberen"} default button 2 with icon caution
			if the button returned of the result is ("Annuleren") then
				continue quit
			end if
		else if SystemLanguage is "no" then
			display dialog ("En annen-applikasjon erpen. Lukk denne for fortsette. Klikk avslutte for Avbryt.") buttons {"avslutte", "Prnytt"} default button 2 with icon caution
			if the button returned of the result is ("avslutte") then
				continue quit
			end if
		else if SystemLanguage is "pt" then
			display dialog ("Tem outra aplicao  aberta; feche-a para continuar. Clique em sair para Cancelar.") buttons {"Sair", "Tentar novamente"} default button 2 with icon caution
			if the button returned of the result is ("Sair") then
				continue quit
			end if
		else if SystemLanguage is "sv" then
			display dialog ("Ett annat-program kurs. Avsluta det fur att fortsetta. Klicka pe  avsluta att Avbryt.") buttons {"Avsluta", "Fursfkigen"} default button 2 with icon caution
			if the button returned of the result is ("Avsluta") then
				continue quit
			end if
			
			
		else
			display dialog ("Another application is open. Please close it to continue. Click on Exit to cancel installation.") buttons {"Exit", "Retry"} default button 2 with icon caution
			if the button returned of the result is ("Exit") then
				continue quit
			end if
			
		end if
		*)
		--display dialog (localized string of "Another application is open. Please close it to continue. Click on Exit to cancel installation.") buttons {localized string of "Exit", localized string of "Retry"} default button 2 with icon caution
		--if the button returned of the result is (localized string of "Exit") then
		--return 1
		--end if
		
		set s to path to me
		
		display dialog (localized string "Another  application is open please close it to continue. 
Click on Cancel to exit." in bundle s) buttons {localized string "Cancel" in bundle s, localized string "Retry" in bundle s}
		
		if the button returned of the result is (localized string "Cancel" in bundle s) then
			continue quit
		end if
		
		
		set command to "ps ax | grep -v grep | grep JavaApplicationStub; exit 0"
		set the_result to do shell script command
		
		if the_result is equal to "" then
			exit repeat
		end if
	end repeat
end tell

