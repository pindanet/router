#!/bin/bash
# http://www.system-rescue-cd.org/manual/Installing_SystemRescueCd_on_the_disk/
# Boot SystemRescueCd and copy system to RAM
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
  linux  /sysresccd/boot/x86_64/vmlinuz archisobasedir=sysresccd archisodevice=$DEVICE copytoram setkmap=be restorewindows
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
  linux  /sysresccd/boot/x86_64/vmlinuz archisobasedir=sysresccd archisodevice=$DEVICE copytoram setkmap=be
  echo   'Loading initramfs ...'
  initrd /sysresccd/boot/x86_64/sysresccd.img
}
EOF
wget -O /mnt/esp/grub/themes/starfield/starfield.png https://raw.githubusercontent.com/pindanet/router/master/clients/snt.png
# wget -O /mnt/esp/autorun https://raw.githubusercontent.com/pindanet/router/master/clients/autorun
umount /mnt/esp
umount /mnt/cdrom
