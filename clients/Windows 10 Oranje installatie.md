#ToDo
#Back-upsysteem Oranje
1. Start de computer
2. Als je 20 seconden wacht start Windows 10 automatisch op.
3. Selecteer binnen de 20 seconden met de pijltoetsen op het toetsenbord de optie Windows 10 terugzetten en druk Return</br>
De back-up met Windows 10 en de extra geïnstalleerde software wordt automatisch teruggezet
4. Selecteer binnen de 20 seconden met de pijltoetsen op het toetsenbord de optie SystemRescueCd (64bit) en druk Return</br>
  Na een tijdje moet je een Opdracht ingeven</br>
    Een overzicht van de mogelijke opdrachten en hun functies:
    * restore: Windows 10 wordt teruggezet naar een vorig herstelpunt
      * parent: vorige back-up terugzetten (bijvoorbeeld bij een beschadigde hoofdback-up)
      * grandparent: oudste back-up terugzetten (bijvoorbeeld bij een beschadigde vorige en hoofdback-up)
      * elke andere keuze: hoofdback-up terugzetten
    * halt: wordt de computer na automatisch uitgeschakeld
    * reboot: wordt de computer automatisch herstart
    * terminal: Kom je in de Linux omgeving
    * backup: maakt een gewone back-up (bijvoorbeeld na het installeren van extra software)
Bij een foutmelding:
* herstart (reboot) met de opdracht
    `shutdown -r now`
* of sluit af (halt) met de opdracht
    `shutdown -h now`

  telkens afsluiten met Return
    
Ik (Dany Pinoy) lever de computers af met een gewone back-up waarin D-schijf deling is opgenomen.

Deling terug zonder wachtwoord (vroeger: snt+456).

# Installatieprocedure Lenovo ThinkCentre 7303-V29
* Opstarttoetsen werken enkel met USB toetsenbord
* F1 Bios instellen
* F12 Boot menu
* Bios updaten met CD
```
sda1	524 MB	ntfs    boot
sda2	128 GB	ntfs	  C:
sda3	318 GB	exFat	  D:
sda4   54 GB  ext4    backup
```
#Windows 10 x64 Pro
1. Windows Setup
  * Te installeren taal: Nederlands (Nederland)
  * Indeling voor tijd en valuta: Nederlands (België)
  * Toetsenbord of invoermethode: Belgisch (punt)
  * Volgende
2. Nu installeren
3. Productcode: Originele Windows 7 Pro OA Productcode gebruikt
4. Ik ga akkoord met de licentievoorwaarden > Volgende
5. Aangepast: alleen Windows installeren (geavanceerd)
6. Partitionering
  * Niet-toegewezen ruimte van station 0
  * Volgende
7. Expressinstellingen gebruiken
8. Ik ben de eigenaar ervan > Volgende
9. Bewijzen dat jij het bent
  * Deze stap overslaan
10. Een account maken voor deze pc
  * Wie gaat deze pc gebruiken? SNT Cursist
  * snt+456
  * snt+456
  * SNT
  * Volgende
11. Computer herstarten
12.Windows + R
  * netplwiz > OK
  * Gebruikers moeten een gebruikersnaam en wachtwoord opgeven ... UITschakelen > OK
  * snt+456
  * snt+456
13. Energiebeheerschema bewerken: 
  * Het beeldscherm uitschakelen na: Nooit
  * De computer in slaapstand zetten: Nooit > Wijzigingen opslaan
14. Energiebeheer > Het gedrag van de aan/uit-knoppen bepalen
  * Instellingen wijzigen die momenteel niet beschikbaar zijn
  * Actie als ik op de aan/uit-knop druk: Afsluiten
  * Wachtwoordbeveiliging tijdens het uit slaapstand komen: Geen wachtwoord vereisen
  * Snel opstarten uitschakelen > Wijzigingen opslaan (noodzakelijk voor het maken en terugzetten van back-ups, NTFS afsluiten)
15. Naar updates zoeken > Wachten tot alle updates gedownload en geïnstalleerd zijn.
  * Nu opnieuw opstarten
16. Naar updates zoeken > Nu installeren > Verschillende malen Opnieuw proberen
  * Nu opnieuw opstarten
  
    (HiDPI: Beeldscherminstellingen > De grootte van tekst, apps en andere items wijzigen: 150%)

17. Informatie over uw pc > Naam van pc wijzigen: OranjePCxx > Volgende > Nu opnieuw opstarten
18. Partities op harde schijf maken en formatteren
  * Cd-rom-station 0 > Snelmenu > Stationsletter en paden wijzigen... > Wijzigen > E > OK
  * Schijf 1, Part 2 > Snelmenu > Verwijderen > Ja
  * Schijf 1, Part 2 > Snelmenu > Nieuw eenvoudig volume... > Volgende > Volgende
    * Deze stationsletter toewijzen: D > Volgende
    * Bestandssysteem: exFAT
    * Volumenaam: Werkschijf > Volgende > Voltooien

      Opdrachtprompt (administrator) > Ja

            format D: /fs:exFAT /Q
            Current volume label: Werkschijf
            Proceed with Format (Y/N)? Y
            Volume label? Werkschijf

30. Werkschijf (D:) > Eigenschappen > Delen > Geavanceerd delen... > Deze map delen, Machtigingen > Iedereen Volledig beheer Toestaan > OK > OK > Sluiten.
    * Instellingen voor geavanceerd delen beheren > Alle netwerken > Met wachtwoord beveiligd delen uitschakelen
      * Wijzigingen opslaan
31. Apparaten en printers > Een printer toevoegen
  * De printer die ik wil staat niet in de lijst
  * Een printer met behulp van een TCP/IP-adres of hostnaam toevoegen
  * Hostnaam of IP-adres: printerpcklas (vroeger: 10.10.7.220, nu dynamisch via DHCP) > Volgende
  * Windows updates
  * Kyocera FS-1300D
  * Deze printer niet delen
32. Netwerken
  * Ja de pc moet door andere pc's en apparaten gevonden worden
33. Computer herstarten
34. Bootmanager > SystemRescueCD starten
  * Backupwachtwoord: sntlcvo (blind typen en eindigen met Return)
  * De computer sluit automatisch af na het voltooien van de back-up

##Windows 10 VMWare
DVD Shrink 3.2, ShareX, Office 365, Wisa, resolutie: 1280 x 720 (Youtube filmformaat)
#Back-upsysteem St Andries aanpassen

    mount /dev/sda4 /livemnt/boot -o rw,remount
    joe /livemnt/boot/autorun
