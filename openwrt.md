# OpenWrt
    gunzip Downloads/openwrt-18.06.4-x86-64-combined-ext4.img.gz
* Copy gunzip Downloads/openwrt-18.06.4-x86-64-combined-ext4.img.gz to USB Stick
* Boot with SystemRescueCD
* Mount USB stick on /mnt
    <pre>dd if=/mnt/gunzip Downloads/openwrt-18.06.4-x86-64-combined-ext4.img.gz of=/dev/sda bs=1M</pre>
* Resize ext4 partition on sda
* vi /etc/config/network
* i
* config interface 'lan', option ipaddr '192.168.0.1'
* Esc:wq
* reboot OpenWrt and reconnect networkconnections on LAN computer
## Mount HDD
Info: https://openwrt.org/docs/guide-user/storage/usb-drives

    opkg update
    opkg install block-mount
    block detect | uci import fstab
    uci set fstab.@mount[-1].enabled='1'
    uci set fstab.@mount[-2].enabled='1'
    uci commit fstab
### Optional: Idle spindown timeout on disks for NAS usage
    opkg update && opkg install hdparm
    hdparm -S 240 /dev/sdb1
    hdparm -S 240 /dev/sdb2
## Samba
info: https://openwrt.org/docs/guide-user/services/nas/samba_configuration

    opkg update
    opkg list | grep samba
    opkg install samba36-server
    opkg install luci-app-samba
    vi /etc/config/samba
    
    config 'sambashare'
        option 'name' 'SNT Cursist'
        option 'path' '/mnt/sdb2'
        option 'create_mask' '0700'
        option 'dir_mask' '0700'
        option read_only 'yes'
        option 'guest_ok' 'yes'
    
    service samba restart
