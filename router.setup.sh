#!/bin/bash
#
# router.setup.sh - script to setup and configure the openSUSE router
# 2017-01 Dany Pinoy <pindanet.be>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Router Instellingen
wan=eth0
lan=eth1
lanip=192.168.0.1     # SNT: 192.168.2.1
lansubnet=192.168.0.0 # SNT: 192.168.2.0
lanrange='192.168.0.2,192.168.0.200'  # SNT: 192.168.2.100,192.168.2.200
wlan="wlan0"    # Netwerkverbinding WiFi Access Point
gateway=`ip route show | grep 'default' | awk '{print $3}'`
wachtwoord=snt+4567
domein='pindanet.home'     # SNT: snt.local
dnsserver1=$gateway    # SNT: 10.10.0.240
dnsserver2='8.8.8.8'   # Google Public DNS
dnsserver3='208.67.220.220'   # OpenDNS

if [ "$1" == "router" ]; then
  zypper --non-interactive up
  # LAN verbinding initialiseren (de netwerkaart moet actief zijn bij het opstarten van de computer)
  cat <<EOF > /etc/sysconfig/network/ifcfg-$lan
BOOTPROTO='none'
BROADCAST=''                                                                                                                         
ETHTOOL_OPTIONS=''                                                                                                                   
IPADDR=''                                                                                                                            
MTU=''                                                                                                                               
NAME='RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller'
NETMASK=''
NETWORK=''
PREFIXLEN=''
REMOTE_IPADDR=''
STARTMODE='auto'
EOF

  # LAN-Bridge verbinding
  # hostapd initialiseert en koppelt wlan0 aan de bridge
  zypper --non-interactive install bridge-utils
  cat <<EOF > /etc/sysconfig/network/ifcfg-br0
BOOTPROTO='static'
BRIDGE='yes'
BRIDGE_FORWARDDELAY='0'
BRIDGE_PORTS='eth1'
BRIDGE_STP='off'
BROADCAST=''
ETHTOOL_OPTIONS=''
IPADDR='$lanip/24'
MTU=''
NAME=''
NETWORK=''
REMOTE_IPADDR=''
STARTMODE='auto'
EOF

  # Routering
  echo "default $gateway - -" > /etc/sysconfig/network/routes

  # Firewall
  sed -i.ori "s|^\(FW_ROUTE=\).*$|\1\"yes\"|" /etc/sysconfig/SuSEfirewall2
  sed -i "s|^\(FW_DEV_INT=\).*$|\1\"br0\"|" /etc/sysconfig/SuSEfirewall2
  sed -i "s|^\(FW_MASQUERADE=\).*$|\1\"yes\"|" /etc/sysconfig/SuSEfirewall2
      
  # DNS proxy en DHCP server http://www.linux.com/learn/tutorials/516220-dnsmasq-for-easy-lan-name-services
  zypper --non-interactive install dnsmasq
  mv /etc/dnsmasq.conf /etc/dnsmasq.conf.ori
  cat <<EOF > /etc/dnsmasq.conf
domain-needed
bogus-priv
domain=$domein
expand-hosts
local=/$domein/
listen-address=127.0.0.1
listen-address=$lanip
bind-interfaces
dhcp-range=lan,$lanrange,4h
dhcp-option=lan,3,0.0.0.0
dhcp-option=lan,6,$lanip
server=$dnsserver1
server=$dnsserver2
server=$dnsserver3
dhcp-option=pxe,66,$lanip
dhcp-match=set:ipxe,175 # iPXE sends a 175 option.
dhcp-boot=tag:ipxe,http://$lanip/menu.ipxe
# Voor BIOS
# dhcp-boot=pxelinux.0
# Voor SystemRescueCD met Grub
dhcp-boot=bootx64.efi
# Voor WinPE met iPXE
# dhcp-boot=ipxe.efi
enable-tftp
tftp-root=/srv/tftpboot
interface=br0
EOF
  
  # Router intern bereikbaar via router.pindanet.home
  echo "$lanip     router.$domein router" >> /etc/hosts

  systemctl enable dnsmasq.service
  
  # TFTP boot server
  chmod o+rx /srv/tftpboot/
  
  mkdir /srv/www/htdocs/tftpboot
  # De SystemRescueCD systeembestanden moeten wel in /var/backup staan
  cp /var/backup/sysrcd/* /srv/www/htdocs/tftpboot/
  
  # voor BIOS
#   wget https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.gz
#   tar xfz syslinux-6.03.tar.gz
#   rm syslinux-6.03.tar.gz
#   cp syslinux-6.03/bios/core/pxelinux.0 /srv/tftpboot/
#   cp syslinux-6.03/bios/com32/elflink/ldlinux/ldlinux.c32 /srv/tftpboot/
#   cp syslinux-6.03/bios/com32/lib/libcom32.c32 /srv/tftpboot/
#   cp syslinux-6.03/bios/com32/libutil/libutil.c32 /srv/tftpboot/
#   cp syslinux-6.03/bios/com32/menu/vesamenu.c32 /srv/tftpboot/
#   cp syslinux-6.03/bios/memdisk/memdisk /srv/tftpboot/
#   rm -r syslinux-6.03/
# 
#   mkdir /srv/tftpboot/pxelinux.cfg
#   cat <<EOF > /srv/tftpboot/pxelinux.cfg/default
# UI vesamenu.c32
# 
# label winpe
#         menu label ^1) WinPE
#         kernel memdisk
#         append iso raw
#         initrd WinPE_amd64.iso
# LABEL systemrescuecd
#         MENU LABEL ^2) SystemRescueCD
#         KERNEL rescue64
#         APPEND initrd=initram.igz dodhcp netboot=http://router.$domein/tftpboot/sysrcd.dat setkmap=be ar_source=http://router.$domein/tftpboot
# EOF
  
  # Voor EFI met iPXE voor WinPE
  wget -P /srv/tftpboot/ http://boot.ipxe.org/ipxe.efi
  wget http://git.ipxe.org/releases/wimboot/wimboot-latest.zip
  unzip wimboot-latest.zip
  rm wimboot-latest.zip
  cp wimboot-*-signed/wimboot /srv/www/htdocs/
  rm -r wimboot-*-signed/
  
  cat <<EOF > /srv/www/htdocs/menu.ipxe
#!ipxe

kernel wimboot
initrd windows/Boot/BCD         BCD
initrd windows/Boot/boot.sdi    boot.sdi
initrd windows/sources/boot.wim boot.wim
boot
EOF
  
  # Voor EFI met Grub voor SystemRescueCD
  mkdir -p /srv/tftpboot/boot/grub
cat <<EOF > /srv/tftpboot/boot/grub/grub.cfg
set timeout=5

menuentry 'SystemRescueCD' --class os {
     insmod net
     insmod efinet
     insmod tftp
     insmod gzio
     insmod part_gpt
     insmod efi_gop
     insmod efi_uga

     # dhcp, tftp server in my network
     set net_default_server=$lanip

     # auto dhcp setup did not work for me, no idea why
     # net_bootp

     # ok let's assign a static address for now
     net_add_addr eno0 efinet0 192.168.0.201

     echo 'Network status: '
     net_ls_cards
     net_ls_addr
     net_ls_routes

     echo 'Loading SystemRescueCD ...'
     linux (http)/tftpboot/rescue64 dodhcp netboot=nfs://router.$domein:/srv/www/htdocs/tftpboot/ setkmap=be

     echo 'Loading initial ramdisk ...'
     initrd (http)/tftpboot/initram.igz
}
EOF

  cd /srv/tftpboot/
  grub2-mkstandalone -d /usr/lib/grub2/x86_64-efi/ -O x86_64-efi --fonts="unicode" -o bootx64.efi boot/grub/grub.cfg
  cd
  
  zypper --non-interactive install nfs-kernel-server
  echo "/srv/www/htdocs/tftpboot/     $lansubnet/24(ro,sync,no_root_squash,no_all_squash,no_subtree_check)" >> /etc/exports
  systemctl enable rpcbind.service
  systemctl start rpcbind.service
  systemctl enable nfsserver.service
  systemctl start nfsserver.service

  # Download bij het opstarten van SystemRescueCD automatisch een script
  echo "wget -P /root/ https://raw.githubusercontent.com/pindanet/router/master/clients/part.sh" > /srv/www/htdocs/tftpboot/autorun
  
  # SoftAP
  zypper --non-interactive install hostapd iw
  cp /etc/hostapd.conf /etc/hostapd.conf.ori
  cat <<EOF > /etc/hostapd.conf
interface=$wlan
driver=nl80211
channel=6
ssid=SoftAP-SNT
hw_mode=g
auth_algs=1
wmm_enabled=1
ieee80211n=1
# ht_capab=[HT40-][SHORT-GI-20][SHORT-GI-40]
wpa=2
wpa_passphrase=$wachtwoord
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP CCMP
rsn_pairwise=CCMP
bridge=br0
EOF

  # Uitschakelen schermbeveiliging
  echo -ne "\033[9;0]" >> /etc/issue

  # Simple monitor 04/2016
  # http://jason.the-graham.com/2013/03/06/how-to-use-systemd-timers/
  cat <<EOF > /root/PindaNetRouter.sh
#!/bin/bash
# scherm wissen
printf "\033c" > /dev/tty1
if [ \`ls -1 /sys/class/net/ | grep "wlan"\` ]; then
  hostapd=\`/usr/bin/systemctl is-active hostapd.service\`
  if [ \$hostapd == "inactive" ] || [ \$hostapd == "failed" ] || [ \$hostapd == "unknown" ]; then # herstart hostapd noodzakelijk
    wlandev=\`ls -1 /sys/class/net/ | grep "wlan"\`
    sed -i "s/wlan./\$wlandev/" /etc/hostapd.conf
    /usr/bin/systemctl restart hostapd.service
  fi
else
  /usr/bin/systemctl stop hostapd.service
fi
dnsmasq=\`/usr/bin/systemctl is-active dnsmasq.service\`
if [ \$dnsmasq == "inactive" ] || [ \$dnsmasq == "failed" ]; then # herstart dnsmasq noodzakelijk
  /usr/bin/systemctl restart dnsmasq.service
fi
/usr/bin/systemctl status dnsmasq.service > /dev/tty1
/usr/bin/systemctl status hostapd.service > /dev/tty1

# plaats het IP adres op het scherm
IPadres=\`/sbin/ip -f inet -oneline addr show $wan | cut -d " " -f7\`
echo
echo -ne "Welkom op de router\nDeze router is bereikbaar via SSH op \$IPadres
2017 Dany Pinoy voor SNT Brugge\n\nusers login: " > /dev/tty1
EOF
  chmod a+x /root/PindaNetRouter.sh
  
  cat <<EOF > /etc/systemd/system/PindaNetRouter.timer
[Unit]
Description=Router Monitor

[Timer]
OnBootSec=1min
OnUnitActiveSec=1m
Unit=PindaNetRouter.service

[Install]
WantedBy=multi-user.target
EOF

  cat <<EOF > /etc/systemd/system/PindaNetRouter.service
[Unit]
Description=Check router every minute

[Service]
Type=simple
ExecStart=/root/PindaNetRouter.sh
EOF
  
  systemctl enable /etc/systemd/system/PindaNetRouter.timer
  systemctl start PindaNetRouter.timer

  # volgen met journalctl -f -u PindaNetRouter.service
  # systemctl list-timers

# Webserver
  zypper --non-interactive install apache2 apache2-mod_fcgid
  systemctl enable apache2.service
  systemctl start apache2.service
  yast2 firewall services add zone=EXT service=service:apache2

# Samba server
  zypper --non-interactive install samba
  echo -e '[SNTcursist]\n\tcomment = Cursist\n\tpath = /usr/home/Documents\n\tread only = yes\n\tpublic = yes\n\thide dot files = no\n' >> /etc/samba/smb.conf
  # schrijftoegang
  echo -e '[SNTbeheerder]\n\tcomment = Leerkracht\n\tpath = /usr/home/Documents\n\thide dot files = no\n\tadmin users = sntbeheerder\n\tforce user = root\n\tforce group = root\n\twritable = yes\n' >> /etc/samba/smb.conf
  (echo $wachtwoord; echo $wachtwoord) | smbpasswd -a sntbeheerder -s
  # execute rechten voor Windows setup
  sed -i -e "/\[global\]/aacl allow execute always = True" /etc/samba/smb.conf

  # Enkel nodig als je via WAN toegang tot smb wilt
  yast2 firewall services add zone=EXT service=service:samba-server

  systemctl start smb.service
  systemctl enable smb.service
  # Netbios
#  sed -i -e "/\[global\]/anetbios name = router" /etc/samba/smb.conf
#  systemctl start nmb.service
#  systemctl enable nmb.service

  # herstart noodzakelijk
  shutdown -r now
fi
# Variabelen met routerinstellingen heruitvoeren
if [ "$1" == "services" ]; then
# Gebruikers aanmaken
  for gebruiker in pc01 pc02 pc03 pc04 pc05 pc06 pc07 pc08 pc09 pc10 pc11 pc12 pc13 pc14 pc15 pc16 pc17 pc18 pc19 pc20 pc21 pc22 pc23 pc24 pc25 pc26 pc27 pc28 pc29 pc30; do
  useradd $gebruiker -p $wachtwoord -d /srv/www/htdocs/$gebruiker -s /bin/false;
  passwd $gebruiker <<EOF
$wachtwoord
$wachtwoord
EOF
  mkdir /srv/www/htdocs/$gebruiker
  chown $gebruiker:users /srv/www/htdocs/$gebruiker
  done

# Mailserver
  zypper --non-interactive remove postfix
  zypper --non-interactive install exim mailx
  sed -i.ori "s/# primary_hostname =/primary_hostname = $domein/" /etc/exim/exim.conf
  sed -i 's/  require verify        = sender/#  require verify        = sender/' /etc/exim/exim.conf
  systemctl enable exim.service
  systemctl start exim.service
# Mailboxen initialiseren
  for gebruiker in pc01 pc02 pc03 pc04 pc05 pc06 pc07 pc08 pc09 pc10 pc11 pc12 pc13 pc14 pc15 pc16 pc17 pc18 pc19 pc20 pc21 pc22 pc23 pc24 pc25 pc26 pc27 pc28 pc29 pc30; do
    echo "Veel plezier met uw electronische Mailbox." | mail -s "Welkom" $gebruiker@$domein
  done
  # # Mailserver testen vanaf andere computer
  # echo "Bericht van dany" | mail -S smtp=smtp://router.pindanet.home:25 -s "Testbericht" pc01@pindanet.home
  # # Ontvangen mails opvragen op de router
  # mail -u pc01

# IMAP server
  zypper --non-interactive install dovecot
  sed -i.ori "s/#mail_location =/mail_location = mbox:~\/Mail:INBOX=\/var\/spool\/mail\/%u/" /etc/dovecot/conf.d/10-mail.conf
  # Uitschakelen gebruik van ssl certificaten
  sed -i.ori "s/#ssl = yes/ssl = no/" /etc/dovecot/conf.d/10-ssl.conf
  systemctl enable dovecot.service
  systemctl start dovecot.service
  # # Testen
  # telnet localhost 143
  #   1 login pc01 snt+4567
  #   1 select inbox
  #   1 logout

# MariaDB server
  zypper --non-interactive install mariadb
  systemctl enable mysql.service
  systemctl start mysql.service
  # mysqladmin -u root password "$wachtwoord"
  # Alternatief voor mysql_secure_installation --use-default op http://howtolamp.com/lamp/mysql/5.6/securing/
  /usr/bin/mysql -e "set password for 'root'@'localhost' = password('$wachtwoord');"
  /usr/bin/mysql --password=$wachtwoord -e "set password for 'root'@'127.0.0.1' = password('$wachtwoord');"
  /usr/bin/mysql --password=$wachtwoord -e "set password for 'root'@'::1' = password('$wachtwoord');"
  /usr/bin/mysql --password=$wachtwoord -e "set password for 'root'@'$HOSTNAME' = password('$wachtwoord');"
  /usr/bin/mysql --password=$wachtwoord -e "flush privileges;"

  /usr/bin/mysql --password=$wachtwoord -e "update mysql.user set password = password('$wachtwoord') where user = '';"
  /usr/bin/mysql --password=$wachtwoord -e "flush privileges;"

  /usr/bin/mysql --password=$wachtwoord -e "delete from mysql.db where Db like 'test%';"
  /usr/bin/mysql --password=$wachtwoord -e "flush privileges;"

  /usr/bin/mysql --password=$wachtwoord -e "drop user ''@'localhost';"
  /usr/bin/mysql --password=$wachtwoord -e "drop user ''@'$HOSTNAME';"

  /usr/bin/mysql --password=$wachtwoord -e "drop database test;"

#  rm $HOME/.mysql_history
#  ln -s /dev/null $HOME/.mysql_history

  sed -i.ori "/# skip-networking/askip-networking" /etc/my.cnf
  service mysql restart

  # /usr/bin/mysql --password=$wachtwoord -e "update mysql.user set user="sqlbeheerder" where user="root";"
  # /usr/bin/mysql --password=$wachtwoord -e "flush privileges;"

  for gebruiker in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do
    query="CREATE USER 'pc$gebruiker'@'localhost' IDENTIFIED BY '$wachtwoord';"
    /usr/bin/mysql --password=$wachtwoord -e "$query"
    query="GRANT USAGE ON * . * TO 'pc$gebruiker'@'localhost' IDENTIFIED BY '$wachtwoord' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;"
    /usr/bin/mysql --password=$wachtwoord -e "$query"
    query="CREATE DATABASE IF NOT EXISTS \`database$gebruiker\`;"
    /usr/bin/mysql --password=$wachtwoord -e "$query"
    query="GRANT ALL PRIVILEGES ON \`database$gebruiker\` . * TO 'pc$gebruiker'@'localhost';"
    /usr/bin/mysql --password=$wachtwoord -e "$query"
  done
  
  # ToDo phpMyAdmin geavanceerde functies instellen

# Webmail
  zypper --non-interactive install php7-pear php7-fileinfo php7-intl php7-bcmath php7-bz2 php7-calendar php7-ctype php7-curl php7-dom php7-ftp php7-gd php7-gettext php7-gmp php7-iconv php7-imap php7-ldap php7-mbstring php7-mcrypt php7-mysql php7-odbc php7-openssl php7-pcntl php7-pgsql php7-posix php7-shmop php7-snmp php7-soap php7-sockets php7-sqlite php7-sysvsem php7-tokenizer php7-wddx php7-xmlrpc php7-xsl php7-zlib php7-exif php7-fastcgi php7-pear php7-sysvmsg php7-sysvshm ImageMagick curl apache2-mod_php7
  # activeer php7
  a2enmod php7
  # # Test Webserver met PHP
  # echo "<?php phpinfo(); ?>" > /srv/www/htdocs/info.php
  # rm /srv/www/htdocs/info.php

  wget https://github.com/roundcube/roundcubemail/releases/download/1.2.3/roundcubemail-1.2.3-complete.tar.gz
  tar xfz roundcubemail-1.2.3-complete.tar.gz -C /srv/www/htdocs/
  rm roundcubemail-1.2.0-complete.tar.gz
  mv /srv/www/htdocs/roundcubemail-1.2.3/ /srv/www/htdocs/webmail/
  chown -R wwwrun /srv/www/htdocs/webmail/temp/
  chown -R wwwrun /srv/www/htdocs/webmail/logs/

  # zypper --non-interactive install roundcubemail
  systemctl restart apache2.service
  /usr/bin/mysql --password=$wachtwoord -e "CREATE USER 'roundcube'@'localhost' IDENTIFIED BY '$wachtwoord';"
  /usr/bin/mysql --password=$wachtwoord -e "GRANT USAGE ON * . * TO 'roundcube'@'localhost' IDENTIFIED BY '$wachtwoord' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0;"
  /usr/bin/mysql --password=$wachtwoord -e "CREATE DATABASE IF NOT EXISTS \`roundcubemail\`;"
  /usr/bin/mysql --password=$wachtwoord -e "GRANT ALL PRIVILEGES ON \`roundcubemail\` . * TO 'roundcube'@'localhost';"
  /usr/bin/mysql --password=$wachtwoord -e "flush privileges;"
  mysql -u root --password=$wachtwoord 'roundcubemail' < /srv/www/htdocs/webmail/SQL/mysql.initial.sql
  cp /srv/www/htdocs/webmail/config/config.inc.php.sample /srv/www/htdocs/webmail/config/config.inc.php
  sed -i.ori "s|^\(\$config\['default_host'\] =\).*$|\1 \'localhost\';|" /srv/www/htdocs/webmail/config/config.inc.php
  sed -i "s|^\(\$config\['db_dsnw'\] =\).*$|\1 \'mysqli://roundcube:${wachtwoord}@localhost/roundcubemail\';|" /srv/www/htdocs/webmail/config/config.inc.php
  sed -i.ori "s|^\(\$config\['mail_domain'\] =\).*$|\1 \'$domein\';|" /srv/www/htdocs/webmail/config/defaults.inc.php
  sed -i.ori "s|^\(\$config\['language'\] =\).*$|\1 \'nl_BE\';|" /srv/www/htdocs/webmail/config/defaults.inc.php
  # Aanmaken standaard postvakken
  sed -i "s|^\(\$config\['create_default_folders'\] =\).*$|\1 true;|" /srv/www/htdocs/webmail/config/defaults.inc.php
  rm -rf /srv/www/htdocs/webmail/installer

# ReadyMedia
  wget http://downloads.sourceforge.net/project/minidlna/minidlna/1.1.5/minidlna-1.1.5_static.tar.gz
  tar xvzf minidlna-1.1.5_static.tar.gz -C /
  rm minidlna-1.1.5_static.tar.gz
  sed -i.ori "/#network_interface=eth0/anetwork_interface=br0" /etc/minidlna.conf
  sed -i "/#user=jmaggard/auser=root" /etc/minidlna.conf
  sed -i "s/media_dir=\/opt/#media_dir=\/opt/" /etc/minidlna.conf
  sed -i "/#media_dir=\/opt/amedia_dir=A,\/home\/sntbeheerder\/Music" /etc/minidlna.conf
  sed -i "/#media_dir=\/opt/amedia_dir=V,\/home\/sntbeheerder\/Videos" /etc/minidlna.conf
  sed -i "/#friendly_name=My DLNA Server/afriendly_name=Pinda DLNA Server" /etc/minidlna.conf

  mkdir /home/sntbeheerder/Videos
  chown sntbeheerder:users /home/sntbeheerder/Videos
  mkdir /home/sntbeheerder/Music
  chown sntbeheerder:users /home/sntbeheerder/Music
  wget --directory-prefix=/home/sntbeheerder/Music/ https://webdesign.pindanet.be/deel2/Linecraft/muziek/erotic_dream.mp3
  wget --output-document=/home/sntbeheerder/Music/erotic_dream.jpg https://webdesign.pindanet.be/deel2/Linecraft/muziek/speedsound.jpg
  wget --output-document=/home/sntbeheerder/Videos/kajimba.mp4 https://webdesign.pindanet.be/deel2/Linecraft/films/kajimba_-_snippets_640x368.mp4
  wget --directory-prefix=/home/sntbeheerder/Videos/ https://webdesign.pindanet.be/deel2/Linecraft/films/kajimba.jpg

  cat <<EOF > /etc/systemd/system/minidlna.service
[Unit]
Description=MiniDLNA UPnP-A/V and DLNA media server
After=network.target

[Service]
Type=forking
PIDFile=/var/run/minidlna.pid
ExecStart=/usr/sbin/minidlnad -P /var/run/minidlna.pid -f /etc/minidlna.conf

[Install]
WantedBy=multi-user.target
EOF
  systemctl start minidlna.service
  systemctl enable minidlna.service

# FTP server
  zypper --non-interactive install vsftpd
  sed -i.ori "s|^\(anonymous_enable=\).*$|\1NO|" /etc/vsftpd.conf
  # sed -i "s|^\(local_enable=\).*$|\1YES|" /etc/vsftpd.conf
  sed -i "s|^\(write_enable=\).*$|\1YES|" /etc/vsftpd.conf
  sed -i "s/#chroot_local_user=YES/chroot_local_user=YES/" /etc/vsftpd.conf
  sed -i "s/#chroot_list_enable=YES/chroot_list_enable=NO/" /etc/vsftpd.conf
  echo 'allow_writeable_chroot=YES' >> /etc/vsftpd.conf
  echo 'user_config_dir=/home' >> /etc/vsftpd.conf
  for gebruiker in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do
    echo "local_root=/srv/www/htdocs/pc$gebruiker" > /home/pc$gebruiker
    echo 'dirlist_enable=YES' >> /home/pc$gebruiker
    echo 'download_enable=YES' >> /home/pc$gebruiker
    echo 'write_enable=YES' >> /home/pc$gebruiker
  done
  systemctl start vsftpd
  systemctl enable vsftpd
  yast2 firewall services add zone=EXT service=service:vsftpd

# NextCloud
  zypper addrepo http://download.opensuse.org/repositories/server:/php:/applications/openSUSE_Leap_42.2/server:php:applications.repo
  zypper --gpg-auto-import-keys refresh
  zypper --non-interactive install nextcloud php7-fileinfo

  systemctl restart apache2.service
  # Surf naar router.pindanet.home/nextcloud
  curl --request POST "http://router.$domein/nextcloud/index.php" --data-urlencode "install=true" --data-urlencode "adminlogin=root" --data-urlencode "adminpass=$wachtwoord" --data-urlencode "adminpass-clone=$wachtwoord" --data-urlencode "directory=/srv/www/htdocs/nextcloud/data" --data-urlencode "dbtype=sqlite" --data-urlencode "dbuser=" --data-urlencode "dbpass=" --data-urlencode "dbpass-clone=" --data-urlencode "dbname=" --data-urlencode "dbhost=localhost"

  # Laat het gebruik van ENV Variabelen in PHP cli toe
  sed -i.ori "s|^\(variables_order =\).*$|\1 \"EGPCS\"|" /etc/php7/cli/php.ini
  chmod +x /srv/www/htdocs/nextcloud/occ
  for gebruiker in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30; do
    sudo -u wwwrun sh -c "export OC_PASS=$wachtwoord; /srv/www/htdocs/nextcloud/occ user:add --password-from-env pc$gebruiker"
  done
  sudo -u wwwrun /srv/www/htdocs/nextcloud/occ user:report
  sed -i -e "/installed/a\  'default_language' => 'nl'," /srv/www/htdocs/nextcloud/config/config.php
#  sed -i -e "/return array(/a\'nl'=>'Nederlands'," /srv/www/htdocs/nextcloud/settings/languageCodes.php

# Monitor Linux Dash
  wget https://github.com/afaqurk/linux-dash/archive/master.zip
  unzip master.zip -d /srv/www/htdocs/
  rm master.zip
  # bekijken via http://router.pindanet.home/linux-dash-master/

  shutdown -h now
fi
if [ "$1" == "windows" ]; then
  # Windows 10 installatiebestanden eenmalig ter beschikbaar stellen
  mkdir /srv/www/htdocs/windows
  mount /usr/home/Documents/WinPE_amd64.iso /srv/www/htdocs/windows/ -o loop
  mkdir /usr/home/Documents/windows
  mount /usr/home/Documents/Windows.iso /usr/home/Documents/windows/ -o loop
  
#  mount /dev/sda1 /mnt
#  mkdir /home/sntbeheerder/windows10
#  lodev=`losetup --partscan --find --show /mnt/Windows10Pro.img`
#  mount $lodev /home/sntbeheerder/windows10/ -o ro

#  mkdir /home/sntbeheerder/windows7
#  lodev=`losetup --partscan --find --show /mnt/window7aio.img`
  # 
  # USB image aanmaken met dd if=/dev/sdb1 of=/mnt/window7aio.img
#  mount $lodev /home/sntbeheerder/windows7/ -o ro
  # terug vrijmaken met
  # umount /dev/loop0
  # losetup -d /dev/loop0
fi

# ToDo
# Horde Groupware
# Prosody IM Jabber/XMPP Server
exit
