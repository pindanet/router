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
* Opstarten met SystemRescueCD vanaf USB

        mount /dev/sda1 /mnt/custom
        mount /dev/sdb1 /mnt/backup
        grub2-install --target=x86_64-efi --efi-directory=/mnt/custom --boot-directory=/mnt/backup --bootloader-id=grub --recheck /dev/sda
        mkdir /mnt/backup/sysrcd
        cp /livemnt/boot/{sysrcd.dat,sysrcd.md5} /mnt/backup/sysrcd/
        cp /livemnt/boot/syslinux/{initram.igz,rescue64} /mnt/backup/sysrcd/
        wget -P /mnt/backup/grub/locale/ http://users.snt.be/dany.p/public_html/installatie/nl.mo
        umount /mnt/custom
        joe /mnt/backup/grub/themes/starfield/theme.txt
            in sectie boot_menu
                item_color = "#fff"
                selected_item_color= "#fff"
        joe /mnt/backup/grub/grub.cfg
            # Global options
            set timeout=8
            set default=0
            set fallback=1
            set pager=1

            # Display settings
            if loadfont /grub/fonts/unicode.pf2 ; then
                    set gfxmode=auto
                    insmod efi_gop
                    insmod efi_uga
                    insmod gfxterm
                    insmod videotest
                    insmod videoinfo
                    terminal_output gfxterm
                    insmod gfxmenu
                    insmod png
                    set theme=/grub/themes/starfield/theme.txt
                    export theme
                    set locale_dir=/grub/locale
                    set lang=nl
                    insmod gettext
            fi
            menuentry "Router starten" {
                    insmod part_gpt
                    insmod gzio
                    insmod part_gpt
                    set root='(hd0,gpt3)'
                    echo 'Laden van Linux 4.4...'
                    linuxefi /boot/vmlinuz root=/dev/sda3 ro resume=/dev/sda2 splash=silent quiet showopts 
                    echo    'Laden van initiële RAM-schijf...'
                    initrdefi /boot/initrd
            }
            menuentry "SystemRescueCd (64bit)" {
                    set gfxpayload=keep
                    set root='(hd1,gpt1)'
                    linux   /sysrcd/rescue64 setkmap=be subdir=sysrcd
                    initrd  /sysrcd/initram.igz
            }
### Updaten enz.
    partclone.extfs --clone --source /dev/sda3 | gzip -c > /mnt/backup/child.linux.partclone.gz

* Backuppartitie koppelen vanaf CD/USB:

        joe /mnt/backup/autorun
* vanaf geïnstalleerd systeem:

        mount /livemnt/boot -o rw,remount
