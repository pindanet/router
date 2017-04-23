# ToDo

# Back-upsysteem
1. Start de computer
2. Als je 20 seconden wacht start Windows 10 automatisch op.
3. Selecteer binnen de 20 seconden met de pijltoetsen op het toetsenbord de optie Windows 10 terugzetten en druk Return</br>
De back-up met Windows 10 en de extra geïnstalleerde software wordt automatisch teruggezet
4. Selecteer binnen de 20 seconden met de pijltoetsen op het toetsenbord de optie SystemRescueCd (64bit) en druk Return</br>
  Na een tijdje moet je een Backupwachtwoord ingeven</br>
  Je moet het wachtwoord blind intypen, er verschijnt tijdens het typen dus niets op het scherm</br>
  Een overzicht van de mogelijke wachtwoorden en hun functies:
    * sntlcvo: maakt een gewone back-up (bijvoorbeeld na het installeren van extra software)
    * herstel: Windows 10 wordt teruggezet naar een minimale basis, dus zonder geïnstalleerde software (fabrieksinstellingen)
    * parent: vorige back-up wordt teruggezet (te gebruiken als de huidige back-up beschadigd is en dus niet werkt)
    * basis: maakt een nieuwe minimale basis back-up (wordt afgeraden en is op eigen risico)
    * sysrec: Kom je in de Linux omgeving
    * ander wachtwoord: wordt de computer na een melding automatisch uitgeschakeld

Bij een foutmelding:
* herstart (reboot) met de opdracht
    `shutdown -r now`
* of sluit af (halt) met de opdracht
    `shutdown -h now`

  telkens afsluiten met Return
    
Ik (Dany Pinoy) heb een minimale Windows 10 back-up gemaakt.

Ik (Dany Pinoy) lever de computers af met een gewone back-up waarin de printerconfiguratie en D-schijf deling is opgenomen.

Deling terug zonder wachtwoord (vroeger: snt+456).

# VMware Player configuratie
1. Maak een Virtuele computer
  * Windows 10 x64
  * 4096 MB geheugen
  * 2 processors
  * 100 GB Harde schijf
  * 60 GB Harde schijf
  * met een NAT en een Bridged interface
2. Start de virtuele computer NIET op.
3. Sluit VMware af.
4. Pas .vmx bestand als volgt aan:

        ethernet0.connectionType = "nat"

   wordt

        ethernet0.connectionType = "pvn"
        ethernet0.pvnID = "52 dd bc d5 36 19 1b 6b-0f f1 fb 1c 4c ac 44 f7"
        firmware = "efi"

5. Start de virtuele computer (voor het starten van de virtuele router)

Het pvnIP moet op beide virtuele computers hetzelfde zijn

# Partitioneren
1. Op router voor de les Thuisnetwerken

        joe /etc/dnsmask.conf
          bootx64.efi inschakelen
          ipxe.efi uitschakelen
        systemctl restart dnsmask.service

2. Esc > Network Boot (F12)
  * IP4 Intel(R) Ethernet Connection I217-LM

  * part.sh wordt van internet gehaald

           joe part.sh
             pas 10% aan naar 80% (tweemaal) voor een grotere backuppartitie
           
           sh part.sh part
           shutdown -r now
```
sda1	450 MB	ntfs    hidden, diag            Basic data partition
sda2	100 MB	fat32	EFI system partition
sda3	16 MB		Microsoft reserved partition
sda4    99 GB  ntfs    C:

sdb	60 GB
sdb1	80%	ext4	SystemRescueCD	(vrijmaken na Windows installatie)
sdb2	20%	ntfs	D:Werkschijf	
```
# Windows 10 x64 Pro
1. Op router voor de les Thuisnetwerken

        joe /etc/dnsmask.conf
          bootx64.efi uitschakelen
          ipxe.efi inschakelen
        systemctl restart dnsmask.service
        sh router.setup.sh windows
2. Esc > EFI Network

            windows\setup.exe
3. Windows Setup
  * Te installeren taal: Nederlands (Nederland)
  * Indeling voor tijd en valuta: Nederlands (België)
  * Toetsenbord of invoermethode: Belgisch (punt)
  * Volgende
4. Nu installeren
5. Productcode: Originele Windows 7 Pro OA Productcode gebruikt
6. Ik ga akkoord met de licentievoorwaarden > Volgende
7. Aangepast: alleen Windows installeren (geavanceerd)
8. Partitionering
  * Niet-toegewezen ruimte van station 0
  * Volgende
9. Instellingen
  * Regio: Belgiê > Ja
  * Toetsenbordindeling: Belgisch (punt) > Ja
  * Tweede toetsenbordindeling Overslaan
10. Instellen voor persoonlijk gebruik > Volgende
11. Account
  * Offlineaccount
  * Wie gaat deze pc gebruiken? SNT Cursist
  * snt+456
  * snt+456
  * SNT
  * Volgende
12. Privacyinstellingen > Akkoord
13. Op router voor de les Thuisnetwerken

        joe /etc/dnsmask.conf
          bootx64.efi inschakelen
          ipxe.efi uitschakelen
        systemctl restart dnsmask.service
14. Computer herstarten
15. Esc > EFI Network
  * part.sh wordt van internet gehaald
  * end of autorun scripts, press Enter to continue

        sh part.sh bootmgr
        shutdown -r now
15. Bootmanager > SystemRescueCD starten
  * Backupwachtwoord: basis (blind typen en eindigen met Return)
  * De computer sluit automatisch af na het voltooien van de back-up
16. Computer starten
17. Windows + R
  * netplwiz > OK
  * Gebruikers moeten een gebruikersnaam en wachtwoord opgeven ... UITschakelen > OK
  * snt+456
  * snt+456
18. VMware Tools installeren
19. Energiebeheerschema bewerken: 
  * Het beeldscherm uitschakelen na: Nooit
  * De computer in slaapstand zetten: Nooit > Wijzigingen opslaan
20. Energiebeheer > Het gedrag van de aan/uit-knoppen bepalen
  * Instellingen wijzigen die momenteel niet beschikbaar zijn
  * Actie als ik op de aan/uit-knop druk: Afsluiten
  * Wachtwoordbeveiliging tijdens het uit slaapstand komen: Geen wachtwoord vereisen
  * Snel opstarten uitschakelen > Wijzigingen opslaan (noodzakelijk voor het maken en terugzetten van back-ups, NTFS afsluiten)
21. Naar updates zoeken > Wachten tot alle updates gedownload en geïnstalleerd zijn.
  * Nu opnieuw opstarten
22. Weerbericht Brugge
23. Computer herstarten
24. Bootmanager > SystemRescueCD starten
  * Backupwachtwoord: sntlcvo (blind typen en eindigen met Return)
  * De computer sluit automatisch af na het voltooien van de back-up
25. Partities op harde schijf maken en formatteren
  * Schijf 1, Part 2 > Snelmenu > Verwijderen > Ja
  * Schijf 1, Part 2 > Snelmenu > Nieuw eenvoudig volume... > Volgende > Volgende
    * Deze stationsletter toewijzen: E > Volgende
    * Bestandssysteem: exFAT (Of FAT32)
    * Volumenaam: Werkschijf > Volgende > Voltooien
26. Werkschijf (D:) > Eigenschappen > Delen > Geavanceerd delen... > Deze map delen, Machtigingen > Iedereen Volledig beheer Toestaan > OK > OK > Sluiten.
    * Instellingen voor geavanceerd delen beheren > Alle netwerken > Met wachtwoord beveiligd delen uitschakelen
      * Wijzigingen opslaan
27. Printer aanzetten en laten detecteren
28. Netwerken
  * Ja de pc moet door andere pc's en apparaten gevonden worden
29. Schermresolutie: 1280 x 720 (YouTube formaat)
30. Computer herstarten
31. Bootmanager > SystemRescueCD starten
  * Backupwachtwoord: sntlcvo (blind typen en eindigen met Return)
  * De computer sluit automatisch af na het voltooien van de back-up

## Software
1. DVD Shrink 3.2
2. ShareX
3. Office 365
4. Wisa
5. Sibelius 7 (10240 MB geheugen)
# Back-upsysteem aanpassen

    mount /dev/sda4 /livemnt/boot -o rw,remount
    joe /livemnt/boot/autorun
