# OpenWrt
* gunzip Downloads/openwrt-18.06.4-x86-64-combined-ext4.img.gz
* Copy gunzip Downloads/openwrt-18.06.4-x86-64-combined-ext4.img.gz to USB Stick
* Boot with SystemRescueCD
* Mount USB stick on /mnt
* dd if=/mnt/gunzip Downloads/openwrt-18.06.4-x86-64-combined-ext4.img.gz of=/dev/sda bs=1M
* Resize ext4 partition on sda
* vi /etc/config/network
* i
* config interface 'lan', option ipaddr '192.168.0.1'
* Esc:wq
* reboot OpenWrt and reconnect networkconnections on LAN computer
## Mount HDD
* opkg update
* opkg install block-mount
* block detect | uci import fstab
* uci set fstab.@mount[-1].enabled='1'
* uci commit fstab

## Samba