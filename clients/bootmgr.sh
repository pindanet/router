#!/bin/bash
# http://www.system-rescue-cd.org/manual/Installing_SystemRescueCd_on_the_disk/
mkdir /mnt/cdrom
mount /dev/sr0 /mnt/cdrom
mkdir /mnt/esp
mount /dev/sda1 /mnt/esp/
