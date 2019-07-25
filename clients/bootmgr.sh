#!/bin/bash
# http://www.system-rescue-cd.org/manual/Installing_SystemRescueCd_on_the_disk/
# Boot SystemRescueCd and copy system to RAM
mkdir /mnt/cdrom
mount /dev/sr0 /mnt/cdrom
mkdir /mnt/esp
mount /dev/sda1 /mnt/esp/
cp -a /mnt/cdrom/sysresccd /mnt/esp/
UUID=$(lsblk -o partlabel,uuid | grep "EFI system partition" | awk '{print $4}')
DEVICE=$(blkid | grep $UUID | cut -d':' -f1)
cat > /etc/grub.d/25_sysresccd <<EOF
#!/bin/sh
exec tail -n +3 $0

menuentry 'SystemRescueCd' {
  load_video
  insmod gzio
  insmod part_gpt
  insmod part_msdos
  insmod ext2
  search --no-floppy --fs-uuid $UUID --set=root --hint hd0,gpt1
#  search --no-floppy --label boot --set=root
  echo   'Loading Linux kernel ...'
  linux  /sysresccd/vmlinuz archisobasedir=sysresccd archisodevice=$DEVICE copytoram setkmap=be
  echo   'Loading initramfs ...'
  initrd /sysresccd/sysresccd.img
}
EOF
