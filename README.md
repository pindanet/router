# openSUSE Router for classrooms
This desribes how to build a router from scratch on a openSUSE Leap 42.2 system.

Meer Nederlandstalige informatie bij [openSUSE Router op PindaNet.be](https://linux.pindanet.be/faq/tips16/router.html).
## HP EliteDesk 800 G1 SFF (procedure getest op VMWare virtuele computers)
VMware Player in vmx configuratiebestand:

    firmware = "efi"
### Schijfbeheer
| Partitie | Grootte | Bestandssyteem | Koppelpunt |
|----------|--------:|:--------------:|------------|
|/dev/sda1 |  512 MB |	          FAT |	/boot/efi  |
|/dev/sda2 |	8 GB |	         swap ||
|/dev/sda1 |  111 GB |	         Ext4 |	/  | 
|||||
|/dev/sdb1 |  100 GB |	         Ext4 |	/var/backup
|/dev/sdb2 |  832 GB |           Ext4 |	/usr/home/Documents
### OpenSuSE Leap 42.2
* Opstarten met installatie x86_64 USB  
* Esc  
* Installation  
* Language: Dutch - Nederlands  
  * Toetsenbordindeling > Belgisch  
* Partitionering door expert...  
  * Apparaten opnieuw scannen  
  * Vaste schijven > sda > sda1 > Bewerken  
    * Aankoppelpunt: /boot/efi > Voltooien  
  * Vaste schijven > sda > sda2 > Bewerken  
    * Formatteer de partitie.  
    * Swap  
    * Aankoppelpunt: swap > Voltooien  
  * Vaste schijven > sda > sda3 > Bewerken  
    * Formatteer de partitie.  
    * Ext4  
    * Aankoppelpunt: / > Voltooien  
  * Vaste schijven > sdb > sdb1 > Bewerken  
    * Formatteer de partitie.  
    * Ext4  
    * Aankoppelpunt: /var/backup > Voltooien  
  * Vaste schijven > sdb > sdb2 > Bewerken  
    * Formatteer de partitie.  
    * Ext4  
    * Aankoppelpunt: /usr/home/Documents > Voltooien  
  * > Accepteren > Volgende  
* Tijdzone:
  * Hardwareklok instellen op UTC inschakelen
  * Tijdzone: België
  * Andere instellingen...
    * Met NTP-server synchroniseren
    * Adres van de NTP-server: be.pool.ntp.org > Accepteren > Volgende
* Bureaubladselectie: Server (tekstmodus) > Volgende
* Nieuwe gebruiker aanmaken
  * SNT Beheerder
  * sntbeheerder
  * snt+4567
  * snt+4567
  * Volgende
* Installatie instellingen:
  * Opstarten > Bootloader: Niet beheerd > Doorgaan > OK
  * Firewall inshakelen, SSH-poort openen en SSH-service inschakelen
  * Installeren > Installeren
* Computer laten herstarten zonder installatie USB
* Aanmelden als root

      zypper up  
      shutdown -r now
### Backupsysteem
