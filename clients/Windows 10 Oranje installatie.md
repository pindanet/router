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
  * Schijf 0, Part 2 > Snelmenu > Volume verkleinen... > naar 121856 MB > OK
  * Schijf 0, Part 3 > Snelmenu > Nieuw eenvoudig volume... >
    * Grootte: 303104 MB
    * Deze stationsletter toewijzen: D > Volgende
    * Bestandssysteem: exFAT
    * Volumenaam: Werkschijf > Volgende > Voltooien
19. Werkschijf (D:) > Eigenschappen > Delen > Geavanceerd delen... > Deze map delen, Machtigingen > Iedereen Volledig beheer Toestaan > OK > OK > Sluiten.
    * Instellingen voor geavanceerd delen beheren > Alle netwerken > Met wachtwoord beveiligd delen uitschakelen
      * Wijzigingen opslaan
20. Netwerken
  * Ja de pc moet door andere pc's en apparaten gevonden worden
21. Software installeren:
  * Firefox
  * VLC
  * Chrome
22. Computer herstarten
23. Boot menu (F12) > SystemRescueCD vanaf USB starten
  * bootmgr: installatie bootmanager en back-upsysteem
  * Computer herstart automatisch
  * Bootmanager > SystemRescueCd (64bit) > backup
  * De computer sluit automatisch af na het voltooien van de back-up
#SystemRescueCD USB autorun script

          #!/bin/bash
          function fout {
            printf "\n\033[1;31;40m %s. Computer NIET uitschakelen. Verwittig de systeembeheerder." "$1"
            read line
            exit
          }
          echo "Automatisch systeemherstel"                                                                                      
          echo "=========================="                                                                                      
          echo "(C) PindaNet.be, Brugge, Dany Pinoy, `date -r /livemnt/boot/autorun +'%d %B %Y'`"                                                                                                          
          echo                                                                                                                   
          echo "Dit is experimentele software.                                                                                 
          Het gebruik ervan is geheel voor eigen risico.                                                                                         
          PindaNet.be en openSUSE e.v. aanvaarden geen enkele aansprakelijkheid voor                                                              
          schade aan hard- en software, verloren gegane data of andere direct of                                                                  
          indirect door het gebruik van deze software ontstane schade.                                                                          
          In sommige landen kunnen de gebruikte software en andere componenten aan                                                                
          exportregelingen of patenten gebonden zijn.                                                                                           
          In deze landen mag deze software niet verspreid worden zoals dat normaal bij
          software onder de gpl-licentie gebruikelijk is.
          Als u het met deze condities niet eens bent, mag u deze software niet
          gebruiken."
          echo
          if [ "`grep restorewindows /proc/cmdline`" ]; then
                  gunzip -c /livemnt/boot/child.windows.img.gz | ntfsclone --restore-image --overwrite /dev/sda2 -
                  if [ $? -ne 0 ]; then
                    fout "Herstellen Windows mislukt"
                  fi
                  shutdown -h now
          fi
          while true; do
            echo
            echo 'Typ een opdracht (restore, halt, reboot, terminal, backup, bootmgr): '
            read keuze
            case "$keuze" in
            "restore")  mount /livemnt/boot -o rw,remount
              echo
              echo 'Welke backup terugzetten (child, parent, grandparent): '
              read keuze
              case "$keuze" in
              "parent") gunzip -c /livemnt/boot/parent.windows.img.gz | ntfsclone --restore-image --overwrite /dev/sda2 -;;
              "grandparent") gunzip -c /livemnt/boot/grandparent.windows.img.gz | ntfsclone --restore-image --overwrite /dev/sda2 -;;
              *) gunzip -c /livemnt/boot/child.windows.img.gz | ntfsclone --restore-image --overwrite /dev/sda2 -;;
              esac;;
            "halt")  echo "De computer wordt automatisch afgesloten."
              echo "U hoeft enkel te wachten..............."
              shutdown -h now
              sleep 3000;;
            "reboot")   echo "De computer wordt automatisch herstart."
              echo "U hoeft enkel te wachten..............."
              shutdown -r now
              sleep 3000;;
            "terminal") break;;
            "backup") mount /livemnt/boot -o rw,remount
              rm /livemnt/boot/grandparent.windows.img.gz
              mv /livemnt/boot/parent.windows.img.gz /livemnt/boot/grandparent.windows.img.gz
              mv /livemnt/boot/child.windows.img.gz /livemnt/boot/parent.windows.img.gz
              ntfsclone --save-image -o - /dev/sda2 | gzip -c > /livemnt/boot/child.windows.img.gz;;
            "bootmgr") start=`parted /dev/sda print | tail -2 | head -1 | awk '{ print $3; }'`
              parted /dev/sda mkpart primary ext4 $start 100%
              partnr=`parted /dev/sda print | tail -2 | head -1 | awk '{ print $1; }'`
                mkfs.ext4 -L systemrescue /dev/sda$partnr
              parted /dev/sda print

              mount /dev/sda$partnr /mnt/gentoo
              grub2-install --root-directory=/mnt/gentoo /dev/sda
              mkdir /mnt/gentoo/sysrcd
              cp /livemnt/boot/{sysrcd.dat,sysrcd.md5} /mnt/gentoo/sysrcd/
              cp /livemnt/boot/syslinux/{initram.igz,rescue64} /mnt/gentoo/sysrcd/
              wget -O /mnt/gentoo/boot/grub/themes/starfield/starfield.png https://github.com/pindanet/router/raw/master/clients/snt.png
              wget -P /mnt/gentoo/boot/grub/locale/ https://github.com/pindanet/router/raw/master/clients/nl.mo
              wget -P /mnt/gentoo/boot/grub/ https://raw.githubusercontent.com/pindanet/router/master/clients/bios/grub.cfg
              sed -i "s/msdos4/msdos$partnr/" /mnt/gentoo/boot/grub/grub.cfg

              cp /livemnt/boot/autorun /mnt/gentoo/
              # bootmgr opdracht uitschakelen
              sed -i "s/backup, bootmgr/backup/" /mnt/gentoo/autorun

              echo "De computer wordt automatisch herstart."
              echo "U hoeft enkel te wachten..............."
              shutdown -r now
              sleep 3000;;
            esac
          done
