#!/bin/bash
# http://www.system-rescue-cd.org/manual/Installing_SystemRescueCd_on_the_disk/
# Boot SystemRescueCd and copy system to RAM
mkdir /mnt/cdrom
mount /dev/sr0 /mnt/cdrom
mkdir /mnt/esp
mount /dev/sda1 /mnt/esp/
cp -a /mnt/cdrom/sysresccd /mnt/esp/
