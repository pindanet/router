#!/bin/bash
if [ -d /sys/firmware/efi ]; then
    if [ "$1" == "part" ]; then
        echo UEFI, dus GPT partitionering
        echo Windows schijf initialiseren
        parted /dev/sda mklabel gpt
	
#        parted /dev/sda mkpart primary ntfs 1MiB 556MB
#        parted /dev/sda set 1 hidden on
#        parted /dev/sda set 1 diag on
#        sgdisk -c 1:"Basic data partition" /dev/sda
#        mkfs.ntfs -Q /dev/sda1

        parted /dev/sda mkpart primary fat32 1MB 2001MB
        parted /dev/sda set 1 boot on
        parted /dev/sda set 1 esp on
        sgdisk -c 1:"EFI system partition" /dev/sda
        mkfs.fat -F32 /dev/sda1
	
        parted /dev/sda print
        echo Gegevensschijf initialiseren
        parted /dev/sdb mklabel gpt
	# Klascomputer
        #parted /dev/sdb mkpart primary ext4 1MiB 10%
        #parted /dev/sdb mkpart primary 10% 100%
	# VMWare Testcomputer
        parted /dev/sdb mkpart primary ext4 1MiB 50%
        parted /dev/sdb mkpart primary 50% 100%
        mkfs.ext4 -L systemrescue /dev/sdb1
        mkfs.ntfs -Q -L Werkschijf /dev/sdb2
        parted /dev/sdb print

# 	start=`parted /dev/sda print | tail -2 | head -1 | awk '{ print $3; }'`
# 	parted /dev/sda mkpart primary ext4 $start 100%
# 	mkfs.ext4 -L systemrescue /dev/sda6
# 	parted /dev/sda print

        echo Installeer nu Windows
        exit
    fi
    if [ "$1" == "bootmgr" ]; then
        mkdir /mnt/custom
	mkdir /mnt/gentoo
        mount /dev/sda2 /mnt/custom
        mount /dev/sdb1 /mnt/gentoo
        grub-install --target=x86_64-efi --efi-directory=/mnt/custom --boot-directory=/mnt/gentoo --bootloader-id=grub --recheck /dev/sda
	
	cp -ar /run/archiso/bootmnt/. /mnt/gentoo/
        label="SYSRCD"$(cat /mnt/gentoo/sysresccd/VERSION)
        label="${label//./}"
        e2label /dev/sdb1 $label
	
	cp -a /mnt/gentoo/boot/. /mnt/custom/boot/
	
	cp /mnt/gentoo/boot/grub/grubsrcd.cfg /mnt/gentoo/grub/grub.cfg

        mkdir /mnt/gentoo/sysrcd
	# voor start vanaf SystemRescueCD.iso (CD-station)
        cp /livemnt/boot/isolinux/{initram.igz,rescue64} /mnt/gentoo/sysrcd/
        cp /livemnt/boot/{sysrcd.dat,sysrcd.md5,initram.igz,rescue64} /mnt/gentoo/sysrcd/
        wget -O /mnt/gentoo/grub/themes/starfield/starfield.png https://raw.githubusercontent.com/pindanet/router/master/clients/snt.png
        wget -P /mnt/gentoo/grub/locale/ https://raw.githubusercontent.com/pindanet/router/master/clients/nl.mo
        wget -O /mnt/gentoo/grub/grub.cfg https://raw.githubusercontent.com/pindanet/router/master/clients/grub.cfg
        wget -O /mnt/gentoo/autorun https://raw.githubusercontent.com/pindanet/router/master/clients/autorun
        umount /mnt/custom
        umount /mnt/gentoo
        exit
    fi
else
# de BIOS versie wordt niet langer onderhouden
	echo BIOS, dus msdos partitionering
	start=`parted /dev/sda print | tail -2 | head -1 | awk '{ print $3; }'`
	parted /dev/sda mkpart primary ext4 $start 100%

	partnr=`parted /dev/sda print | tail -2 | head -1 | awk '{ print $1; }'`

	mkfs.ext4 -L systemrescue /dev/sda$partnr
	parted /dev/sda print

	mount /dev/sda$partnr /mnt/gentoo
	grub2-install --root-directory=/mnt/gentoo /dev/sda
	mkdir /mnt/gentoo/sysrcd
	cp /livemnt/boot/{sysrcd.dat,sysrcd.md5} /mnt/gentoo/sysrcd/
	# vanaf tftp
	curl tftp://router.pindanet.home/rescue64 > /mnt/gentoo/sysrcd/rescue64
	curl tftp://router.pindanet.home/initram.igz > /mnt/gentoo/sysrcd/initram.igz
	# vanaf CD/USB
	# cp /livemnt/boot/isolinux/{initram.igz,rescue64} /mnt/gentoo/sysrcd/
	wget -O /mnt/gentoo/boot/grub/themes/starfield/starfield.png http://users.snt.be/dany.p/public_html/installatie/snt.png
	wget -P /mnt/gentoo/boot/grub/locale/ http://users.snt.be/dany.p/public_html/installatie/nl.mo
	wget -P /mnt/gentoo/boot/grub/ http://users.snt.be/dany.p/public_html/installatie/bios/grub.cfg
	sed -i "s/msdos4/msdos$partnr/" /mnt/gentoo/boot/grub/grub.cfg
	wget -P /mnt/gentoo/ http://users.snt.be/dany.p/public_html/installatie/bios/autorun
	umount /mnt/gentoo
fi
