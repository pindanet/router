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
    
    option 'homes'                  '0'

    vi /etc/samba/smb.conf.template
    
    [SNT Cursist]                       
        path = /mnt/sdb2                      
        read only = yes           
        guest ok = yes              
        create mask = 0700                    
        directory mask = 0700     
                                  
    [SNT Beheerder]                               
        path = /mnt/sdb2                      
        valid users = sntbeheerder
        read only = no            
        force user = root 
        force group = root   
    
    vi /etc/passwd
    
    sntbeheerder:*:1000:65534:sntbeheerder:/var:/bin/false
    
    smbpasswd -a sntbeheerder
    service samba restart
## Users
    wachtwoord=snt+4567
    userid=1000
    for gebruiker in pc01 pc02 pc03 pc04 pc05 pc06 pc07 pc08 pc09 pc10 pc11 pc12 pc13 pc14 pc15 pc16 pc17 pc18 pc19 pc20 pc21 pc22 pc23 pc24 pc25 pc26 pc27 pc28 pc29 pc30; do
    userid=$((userid + 1))
    echo "$gebruiker:*:$userid:100:$gebruiker:/mnt/sdb2/home/$gebruiker:/bin/false" >> /etc/passwd
    passwd $gebruiker <<EOF
    $wachtwoord
    $wachtwoord
    EOF
    mkdir -p /mnt/sdb2/home/$gebruiker
    chown $gebruiker:users /mnt/sdb2/home/$gebruiker
    done
## FTP
    opkg update && opkg install vsftpd
    service vsftpd enable
    service vsftpd start
