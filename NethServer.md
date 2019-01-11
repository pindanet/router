* ESC > boot from DVD
* Other NethServer installation methods
* Manual installation
* Keyboard > + Dutch; Flemish (Belgian), - English (US)
* Date & Time > Region: Europe, City: Brussels
* Language support > Nederlands > Nederlands (België) activeren
* Installation Destination > ATA SAMSUNG MZ7PD128 (sda), Automatiocally configure partitioning, I would like to make additional space available > Done
* Delete all > Reclaim space
* Network & Hostname > Ethernet (eno1): On, Host name: router.pindanet.home > Apply
* Begin Installation
* Root password > snt+4567 > Done > Done
* User creation > SNT Beheerder, sntbeheerder, snt+4567 > Done > Done
* Reboot
* Remove DVD
* Surf naar https://IPAdres:980 > Certificaat accepteren
* Username: root, Password: snt+4567 > LOGIN
* Welcome, Restore configuration, Set host name, Date and iime, SSH, Smarthost, Usage statistics > NEXT > Apply
* Configuration - Network: enp2s0 > Configure
* Role: LAN (green), IP address: 192.168.0.1, Netmask: 255.255.255.0 > Submit
* Configuration - Network: eno1 > Edit
* Role: Internet (red), DHCP > Submit
* Configuration - Network - DNS servers: Secondary DNS: 8.8.8.8 > Submit
* Configuration - DHCP: enable enp2s0, IP range: 192.168.0.2 -192.168.0.254 > Submit
* Configuration - Backup (configuration)
