#ToDo
#Back-upsysteem St Andries
Start de computer

1. Als je 20 seconden wacht start Windows 10 automatisch op.
2. Selecteer binnen de 20 seconden met de pijltoetsen op het toetsenbord de optie Windows 10 terugzetten en druk Return</br>
De back-up met Windows 10 en de extra geïnstalleerde software wordt automatisch teruggezet
3. Selecteer binnen de 20 seconden met de pijltoetsen op het toetsenbord de optie SystemRescueCd (64bit) en druk Return</br>
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

# Installatieprocedure HP EliteDesk 800 G1 SFF St Andries
1. Esc > Computer Setup (F10)
2. Bestand > Systeem-ROM flashen
  vanaf USB-stick
3. Security > System Security
  * Virtualization Technology (VTx) Enabled
  * Virtualization Technology Directed I/O (VTd) Enabled
  * F10=Accept
4. Geavanceerd > Optie ROM startbeleid
  * PXE Opties ROM's Alleen UEFI
  * Opslag Opties ROM's Alleen UEFI
  * Video Opties ROM's Alleen UEFI
  * F10-Accepteer
5. File > Save Changes and Exit > Yes

##VMware Player testconfiguratie
1. Maak een Virtuele computer met een NAT en een Bridged interface.
2. Start de virtuele computer NIET op.
3. Sluit VMware af.
4. Pas .vmx bestand als volgt aan:

        ethernet0.connectionType = "nat"

   wordt

        ethernet0.connectionType = "pvn"
        ethernet0.pvnID = "52 dd bc d5 36 19 1b 6b-0f f1 fb 1c 4c ac 44 f7"
        firmware = "efi"

5. Start de virtuele computer

Het pvnIP moet op beide virtuele computers hetzelfde zijn

#Partitioneren
1. Op router voor de les Thuisnetwerken

        joe /etc/dnsmask.conf
          bootx64.efi inschakelen
          ipxe.efi uitschakelen
        systemctl restart dnsmask.service

2. Esc > Network Boot (F12)
  * IP4 Intel(R) Ethernet Connection I217-LM

  * part.sh wordt van internet gehaald
```
sh part.sh part
shutdown -r now

sda1	500 MB	ntfs    hidden, diag            Basic data partition
sda2	105 MB	fat32	EFI system partition
sda3	17 MB		Microsoft reserved partition
sda4    127 GB  ntfs    C:

sdb	750 GB
sdb1	10%	ext4	SystemRescueCD	(vrijmaken na Windows installatie)
sdb2	90%	ntfs	D:Werkschijf	
```
#Windows 10 x64 Pro St Andries
1. Op router voor de les Thuisnetwerken
```
joe /etc/dnsmask.conf
  bootx64.efi uitschakelen
  ipxe.efi inschakelen
systemctl restart dnsmask.service
sh router.setup.sh windows
```
2. Esc > Network Boot (F12)
  * IP4 Intel(R) Ethernet Connection I217-LM
```
windows\setup.exe
```
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
9. Expressinstellingen gebruiken
10. Ik ben de eigenaar ervan > Volgende
11. Bewijzen dat jij het bent
  * Deze stap overslaan
12. Een account maken voor deze pc
  * Wie gaat deze pc gebruiken? SNT Cursist
  * snt+456
  * snt+456
  * SNT
  * Volgende
13. Op router voor de les Thuisnetwerken
```
joe /etc/dnsmask
  bootx64.efi inschakelen
  ipxe.efi uitschakelen
systemctl restart dnsmask.service
```
14. Computer herstarten
15. Esc > Network Boot (F12) > IP4 Intel(R) Ethernet Connection I217-LM
  * part.sh wordt van internet gehaald
  * end of autorun scripts, press Enter to continue
```
sh part.sh bootmgr
shutdown -r now
```
15. Bootmanager > SystemRescueCD starten
  * Backupwachtwoord: basis (blind typen en eindigen met Return)
  * De computer sluit automatisch af na het voltooien van de back-up
16. Computer starten
17.Windows + R
  * netplwiz > OK
  * Gebruikers moeten een gebruikersnaam en wachtwoord opgeven ... UITschakelen > OK
  * snt+456
  * snt+456

(VMware Tools installeren)
  
18. Energiebeheerschema bewerken: 
  * Het beeldscherm uitschakelen na: Nooit
  * De computer in slaapstand zetten: Nooit > Wijzigingen opslaan
19. Energiebeheer > Het gedrag van de aan/uit-knoppen bepalen
  * Instellingen wijzigen die momenteel niet beschikbaar zijn
  * Actie als ik op de aan/uit-knop druk: Afsluiten
  * Wachtwoordbeveiliging tijdens het uit slaapstand komen: Geen wachtwoord vereisen
  * Snel opstarten uitschakelen > Wijzigingen opslaan (noodzakelijk voor het maken en terugzetten van back-ups, NTFS afsluiten)
20. Naar updates zoeken > Wachten tot alle updates gedownload en geïnstalleerd zijn.
  * Nu opnieuw opstarten
21. Naar updates zoeken > Nu installeren > Verschillende malen Opnieuw proberen
  * Nu opnieuw opstarten
  
(HiDPI: Beeldscherminstellingen > De grootte van tekst, apps en andere items wijzigen: 150%)

22. Informatie over uw pc > Naam van pc wijzigen: PCxx > Volgende > Nu opnieuw opstarten

23. HP Support Assistant installeren vanaf de router
24. HP Support Assistant opstarten
  * Aanbevolen opties INschakelen > Volgende > OK
  * Controleren op updates en berichten
  * Updates > Aanvinken > Downloaden en installeren
  * Nu opnieuw opstarten > Sluiten
25. HP Support Assistant opstarten
  * Berichten
    * Alle berichten verwijderen > Sluiten
26. Computer herstarten
27. Bootmanager > SystemRescueCD starten
  * Backupwachtwoord: sntlcvo (blind typen en eindigen met Return)
  * De computer sluit automatisch af na het voltooien van de back-up
28. Computer in het netwerk van de Triangel herstarten naar Windows 10
29. Partities op harde schijf maken en formatteren
  * Cd-rom-station 0 > Snelmenu > Stationsletter en paden wijzigen... > Wijzigen > E > OK
  * Schijf 1, Part 2 > Snelmenu > Verwijderen > Ja
  * Schijf 1, Part 2 > Snelmenu > Nieuw eenvoudig volume... > Volgende > Volgende
    * Deze stationsletter toewijzen: D > Volgende
    * Bestandssysteem: exFAT
    * Volumenaam: Werkschijf > Volgende > Voltooien

Opdrachtprompt (administrator) > Ja
```
format D: /fs:exFAT /Q
Current volume label: Werkschijf
Proceed with Format (Y/N)? Y
Volume label? Werkschijf
```  
Werkschijf (D:) > Eigenschappen > Delen > Geavanceerd delen... > Deze map delen, Machtigingen > Iedereen Volledig beheer Toestaan > OK > OK > Sluiten.
Instellingen voor geavanceerd delen beheren > Alle netwerken > Met wachtwoord beveiligd delen uitschakelen
  Wijzigingen opslaan

Apparaten en printers > Een printer toevoegen
  De printer die ik wil staat niet in de lijst
  Een printer met behulp van een TCP/IP-adres of hostnaam toevoegen
  Hostnaam of IP-adres: 10.10.7.220 > Volgende
  Windows updates
  Kyocera FS-1300D
  Deze printer niet delen

Netwerken
  Ja de pc moet door andere pc's en apparaten gevonden worden

Computer herstarten

Bootmanager > SystemRescueCD starten
  Backupwachtwoord: sntlcvo (blind typen en eindigen met Return)
  De computer sluit automatisch af na het voltooien van de back-up

Windows 10 VMWare
=================
DVD Shrink 3.2, ShareX, Office 365, Wisa, resolutie: 1280 x 720 (Youtube filmformaat)

Back-upsysteem St Andries aanpassen
===================================
mount /dev/sda4 /livemnt/boot -o rw,remount
joe /livemnt/boot/autorun
