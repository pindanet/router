#!/bin/bash
function fout {
	printf "\n\033[1;31;40m %s. Computer NIET uitschakelen. Verwittig de systeembeheerder." "$1"
	read line
}
echo Welkom bij het PindaNet SNT Backupsysteem
if [ "`grep restorewindows /proc/cmdline`" ]; then
        #gunzip -c /mnt/backup/windows.img.gz | ntfsclone --restore-image --overwrite /dev/sda3 -
        gunzip -c /mnt/backup/windows.img.gz | ntfsclone --restore-image --overwrite /dev/nvme0n1p3 -
        if [ $? -ne 0 ]; then
        	fout "Herstellen Windows mislukt"
        fi
        shutdown -h now
fi
setkmap be-latin1
read -s -p "Backupwachtwoord: " wachtwoord
echo
if [ $wachtwoord == "sntlcvo" ]; then
        rm /mnt/backup/windows.parent.img.gz
        mv /mnt/backup/windows.img.gz /mnt/backup/windows.parent.img.gz 
        #ntfsclone --save-image -o - /dev/sda3 | gzip -c > /mnt/backup/windows.img.gz
	ntfsclone --save-image -o - /dev/nvme0n1p3 | gzip -c > /mnt/backup/windows.img.gz
        if [ $? -ne 0 ]; then
        	fout "Windows back-up aanmaken mislukt"
        fi
        shutdown -h now
fi
if [ $wachtwoord == "basis" ]; then
        #ntfsclone --save-image -o - /dev/sda3 | gzip -c > /mnt/backup/windows.basis.img.gz
	ntfsclone --save-image -o - /dev/nvme0n1p3 | gzip -c > /mnt/backup/windows.basis.img.gz
        if [ $? -ne 0 ]; then
        	fout "Windows back-up aanmaken mislukt"
        fi
        shutdown -h now
fi
if [ $wachtwoord == "herstel" ]; then
        #gunzip -c /mnt/backup/windows.basis.img.gz | ntfsclone --restore-image --overwrite /dev/sda3 -
	gunzip -c /mnt/backup/windows.basis.img.gz | ntfsclone --restore-image --overwrite /dev/nvme0n1p3 -
        if [ $? -ne 0 ]; then
        	fout "Herstellen Windows mislukt"
        fi
        shutdown -h now
fi
if [ $wachtwoord == "parent" ]; then
        #gunzip -c /mnt/backup/windows.parent.img.gz | ntfsclone --restore-image --overwrite /dev/sda3 -
	gunzip -c /mnt/backup/windows.parent.img.gz | ntfsclone --restore-image --overwrite /dev/nvme0n1p3 -
        if [ $? -ne 0 ]; then
        	fout "Herstellen Windows mislukt"
        fi
        shutdown -h now
fi
if [ $wachtwoord != "sysrec" ]; then
        printf '\033[1;31;40m Foutief Backupwachtwoord. Computer wordt binnen de minuut afgesloten.'
        sleep 60
        shutdown -h now
fi
