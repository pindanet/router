#!/bin/bash
if [ -d /sys/firmware/efi ]; then
    if [ "$1" == "part" ]; then
        echo UEFI, dus GPT partitionering
        echo Windows schijf initialiseren
        # Klascomputer
        #schijf="/dev/sda"
	# VMWare Testcomputer
	schijf="/dev/nvme0n1"
        parted $schijf mklabel gpt
	
        parted $schijf mkpart primary fat32 1MB 2001MB
        parted $schijf set 1 boot on
        parted $schijf set 1 esp on
        sgdisk -c 1:"EFI system partition" $schijf
	# Klascomputer
        #mkfs.fat -F32 "$schijf"1
	# VMWare Testcomputer
	mkfs.fat -F32 "$schijf"p1
	
        parted $schijf print
	
        echo Gegevensschijf initialiseren
        # Klascomputer
        #schijf="/dev/sdb"
	# VMWare Testcomputer
	schijf="/dev/nvme0n2"
        parted $schijf mklabel gpt
	# Klascomputer
        #parted $schijf mkpart primary ext4 1MiB 10%
        #parted $schijf mkpart primary 10% 100%
	# VMWare Testcomputer
        parted $schijf mkpart primary ext4 1MiB 50%
        parted $schijf mkpart primary 50% 100%
        # Klascomputer
        #mkfs.ext4 -L systemrescue "$schijf"1
        #mkfs.ntfs -Q -L Werkschijf "$schijf"2
	# VMWare Testcomputer
        parted $schijf print
        mkfs.ext4 -L systemrescue "$schijf"p1
        mkfs.ntfs -Q -L Werkschijf "$schijf"p2

        echo Installeer nu Windows
        exit
    fi
    if [ "$1" == "bootmgr" ]; then
        mkdir /mnt/cdrom
        mount /dev/sr0 /mnt/cdrom
        mkdir /mnt/esp
        mount /dev/sda1 /mnt/esp/
        cp -a /mnt/cdrom/sysresccd /mnt/esp/
        grub-install --target=x86_64-efi --efi-directory=/mnt/esp --boot-directory=/mnt/esp --bootloader-id=grub --recheck /dev/sda
        UUID=$(lsblk -o partlabel,uuid | grep "EFI system partition" | awk '{print $4}')
        DEVICE=$(blkid | grep $UUID | cut -d':' -f1)
        cat > /mnt/esp/grub/grub.cfg <<EOF
# Global options
set timeout=20
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
menuentry "Windows 10 starten" {
  insmod part_gpt
  insmod chain
  set root='(hd0,gpt1)'
  chainloader /efi/Microsoft/Boot/bootmgfw.efi 
}
menuentry "Windows 10 terugzetten" {
  insmod gzio
  insmod part_gpt
  insmod part_msdos
  insmod ext2
  set root='(hd0,gpt1)'
  echo   'Loading Linux kernel ...'
  linux  /sysresccd/boot/x86_64/vmlinuz archisobasedir=sysresccd archisodevice=$DEVICE copytoram setkmap=be ar_source=$DEVICE restorewindows
  echo   'Loading initramfs ...'
  initrd /sysresccd/boot/x86_64/sysresccd.img
}
menuentry 'SystemRescueCd (64bit)' {
  insmod gzio
  insmod part_gpt
  insmod part_msdos
  insmod ext2
  set root='(hd0,gpt1)'
  echo   'Loading Linux kernel ...'
  linux  /sysresccd/boot/x86_64/vmlinuz archisobasedir=sysresccd archisodevice=$DEVICE copytoram setkmap=be ar_source=$DEVICE
  echo   'Loading initramfs ...'
  initrd /sysresccd/boot/x86_64/sysresccd.img
}
EOF
        wget -O /mnt/esp/grub/themes/starfield/starfield.png https://raw.githubusercontent.com/pindanet/router/master/clients/snt.png
        cat > /mnt/esp/autorun <<EOF
#!/sbin/bash
mkdir /mnt/backup
mount /dev/sdb1 /mnt/backup/
echo '. /mnt/backup/pindanet.sh' >> /root/.bashrc
EOF
        mkdir /mnt/backup
        mount /dev/sdb1 /mnt/backup/
        wget -O /mnt/backup/pindanet.sh https://raw.githubusercontent.com/pindanet/router/master/clients/pindanet.sh
        umount /mnt/esp
        umount /mnt/cdrom
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
