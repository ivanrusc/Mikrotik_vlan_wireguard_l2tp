# =============================================================================
# MikroTik RB750Gr3 (hEX) - DIGI + VLAN + Firewall - FASE 1
# RouterOS: 7.20.7
#
# WAN: ether1 -> VLAN 20 -> PPPoE DIGI
# MGMT: ether2 untagged -> 192.168.1.0/24
# TRUNKS: ether3, ether4, ether5 -> VLAN 131-135 tagged
#
# VLAN131 WIFI      192.168.131.0/24  DHCP .100-.200
# VLAN132 PROXMOX   192.168.132.0/24  sense DHCP
# VLAN133 CT-VM     192.168.133.0/24  DHCP .100-.200
# VLAN134 RESERVAT  192.168.134.0/24  bloquejada
# VLAN135 RESERVAT  192.168.135.0/24  bloquejada
#
# IMPORTANT:
# - Pensat per una configuracio neta.
# - NO executa reset-configuration.
# - Substituir USUARI@digi i CONTRASENYA.
# - Aplicar preferiblement amb WinBox Safe Mode.
# - IPv6 validat en RB750Gr3 / RouterOS 7.20.7 el 2026-09-07.
# - En l'equip provat, no habilitar allow-reconfigure al DHCPv6 client.
# - DHCPv6-PD -> pool6-DIGI -> /64 per LAN/VLAN amb from-pool.
# =============================================================================

/system identity
set name="RTR-MikroTik-VLAN"

/system clock
set time-zone-name=Europe/Madrid

/interface ethernet
set [find default-name=ether1] comment="WAN - ONT DIGI"
set [find default-name=ether2] comment="ACCESS - MGMT 192.168.1.0/24"
set [find default-name=ether3] comment="TRUNK - VLAN 131-135"
set [find default-name=ether4] comment="TRUNK - VLAN 131-135"
set [find default-name=ether5] comment="TRUNK - VLAN 131-135"

# Bridge: VLAN filtering es deixa desactivat fins al final.
/interface bridge
add name=bridge-LAN protocol-mode=rstp vlan-filtering=no comment="Bridge LAN/VLAN principal"

/interface bridge port
add bridge=bridge-LAN interface=ether2 pvid=1 ingress-filtering=yes frame-types=admit-only-untagged-and-priority-tagged comment="ACCESS MGMT"
add bridge=bridge-LAN interface=ether3 ingress-filtering=yes frame-types=admit-only-vlan-tagged comment="TRUNK VLAN 131-135"
add bridge=bridge-LAN interface=ether4 ingress-filtering=yes frame-types=admit-only-vlan-tagged comment="TRUNK VLAN 131-135"
add bridge=bridge-LAN interface=ether5 ingress-filtering=yes frame-types=admit-only-vlan-tagged comment="TRUNK VLAN 131-135"

/interface bridge vlan
add bridge=bridge-LAN vlan-ids=1 untagged=bridge-LAN,ether2 comment="MGMT untagged"
add bridge=bridge-LAN vlan-ids=131 tagged=bridge-LAN,ether3,ether4,ether5 comment="VLAN131 WIFI"
add bridge=bridge-LAN vlan-ids=132 tagged=bridge-LAN,ether3,ether4,ether5 comment="VLAN132 PROXMOX"
add bridge=bridge-LAN vlan-ids=133 tagged=bridge-LAN,ether3,ether4,ether5 comment="VLAN133 CT-VM"
add bridge=bridge-LAN vlan-ids=134 tagged=bridge-LAN,ether3,ether4,ether5 comment="VLAN134 RESERVAT"
add bridge=bridge-LAN vlan-ids=135 tagged=bridge-LAN,ether3,ether4,ether5 comment="VLAN135 RESERVAT"

/interface vlan
add name=vlan131-WIFI interface=bridge-LAN vlan-id=131 comment="WIFI"
add name=vlan132-PROXMOX interface=bridge-LAN vlan-id=132 comment="PROXMOX"
add name=vlan133-CTVM interface=bridge-LAN vlan-id=133 comment="CT-VM"
add name=vlan134-RESERVAT interface=bridge-LAN vlan-id=134 comment="RESERVAT"
add name=vlan135-RESERVAT interface=bridge-LAN vlan-id=135 comment="RESERVAT"

/interface list
add name=IF-WAN comment="WAN IP"
add name=IF-MGMT comment="LAN de gestio"
add name=IF-WIFI comment="VLAN WiFi"
add name=IF-PROXMOX comment="VLAN Proxmox"
add name=IF-CTVM comment="VLAN CT-VM"
add name=IF-RESERVED comment="VLAN reservades"
add name=IF-INTERNAL-ACTIVE comment="Xarxes internes actives"

/interface list member
add list=IF-MGMT interface=bridge-LAN
add list=IF-WIFI interface=vlan131-WIFI
add list=IF-PROXMOX interface=vlan132-PROXMOX
add list=IF-CTVM interface=vlan133-CTVM
add list=IF-RESERVED interface=vlan134-RESERVAT
add list=IF-RESERVED interface=vlan135-RESERVAT
add list=IF-INTERNAL-ACTIVE interface=bridge-LAN
add list=IF-INTERNAL-ACTIVE interface=vlan131-WIFI
add list=IF-INTERNAL-ACTIVE interface=vlan132-PROXMOX
add list=IF-INTERNAL-ACTIVE interface=vlan133-CTVM

/ip address
add address=192.168.1.1/24 interface=bridge-LAN comment="GW MGMT"
add address=192.168.131.1/24 interface=vlan131-WIFI comment="GW VLAN131 WIFI"
add address=192.168.132.1/24 interface=vlan132-PROXMOX comment="GW VLAN132 PROXMOX"
add address=192.168.133.1/24 interface=vlan133-CTVM comment="GW VLAN133 CT-VM"
add address=192.168.134.1/24 interface=vlan134-RESERVAT comment="GW VLAN134 RESERVAT"
add address=192.168.135.1/24 interface=vlan135-RESERVAT comment="GW VLAN135 RESERVAT"

/ip pool
add name=pool-MGMT ranges=192.168.1.100-192.168.1.200
add name=pool-WIFI ranges=192.168.131.100-192.168.131.200
add name=pool-CTVM ranges=192.168.133.100-192.168.133.200

/ip dhcp-server
add name=DHCP-MGMT interface=bridge-LAN address-pool=pool-MGMT lease-time=1d disabled=no
add name=DHCP-WIFI interface=vlan131-WIFI address-pool=pool-WIFI lease-time=1d disabled=no
add name=DHCP-CTVM interface=vlan133-CTVM address-pool=pool-CTVM lease-time=1d disabled=no

/ip dhcp-server network
add address=192.168.1.0/24 gateway=192.168.1.1 dns-server=192.168.1.1 comment="MGMT"
add address=192.168.131.0/24 gateway=192.168.131.1 dns-server=192.168.131.1 comment="WIFI"
add address=192.168.133.0/24 gateway=192.168.133.1 dns-server=192.168.133.1 comment="CT-VM"

/ip dns
set allow-remote-requests=yes

/interface vlan
add name=vlan20-DIGI interface=ether1 vlan-id=20 comment="DIGI Internet VLAN 20"

/interface pppoe-client
add name=PPPoE-DIGI interface=vlan20-DIGI user="USUARI@digi" password="CONTRASENYA" add-default-route=yes use-peer-dns=yes profile=default disabled=no comment="Internet DIGI PPPoE"

/interface list member
add list=IF-WAN interface=PPPoE-DIGI

/ip firewall address-list
add list=NET-MGMT address=192.168.1.0/24 comment="Management"
add list=NET-WIFI address=192.168.131.0/24 comment="WiFi"
add list=NET-PROXMOX address=192.168.132.0/24 comment="Proxmox"
add list=NET-CTVM address=192.168.133.0/24 comment="CT-VM"
add list=NET-RESERVED address=192.168.134.0/24 comment="VLAN134 reservada"
add list=NET-RESERVED address=192.168.135.0/24 comment="VLAN135 reservada"

add list=NET-INTERNAL address=192.168.1.0/24
add list=NET-INTERNAL address=192.168.131.0/24
add list=NET-INTERNAL address=192.168.132.0/24
add list=NET-INTERNAL address=192.168.133.0/24
add list=NET-INTERNAL address=192.168.134.0/24
add list=NET-INTERNAL address=192.168.135.0/24

add list=NET-DNS-CLIENTS address=192.168.1.0/24
add list=NET-DNS-CLIENTS address=192.168.131.0/24
add list=NET-DNS-CLIENTS address=192.168.132.0/24
add list=NET-DNS-CLIENTS address=192.168.133.0/24

add list=NET-INTERNET-ALLOWED address=192.168.1.0/24
add list=NET-INTERNET-ALLOWED address=192.168.131.0/24
add list=NET-INTERNET-ALLOWED address=192.168.132.0/24
add list=NET-INTERNET-ALLOWED address=192.168.133.0/24

# Exemples d'excepcions:
# /ip firewall address-list add list=HOSTS-ALLOWED address=192.168.133.10 comment="Excepcio inter-VLAN"
# /ip firewall address-list add list=HOSTS-BLOCKED address=192.168.131.50 comment="Equip bloquejat"

/ip firewall nat
add chain=srcnat action=masquerade src-address-list=NET-INTERNET-ALLOWED out-interface-list=IF-WAN comment="NAT IPv4 - xarxes autoritzades -> Internet"

/ip firewall filter
add chain=input action=accept connection-state=established,related,untracked comment="IPv4 INPUT 010 - established related"
add chain=input action=drop connection-state=invalid comment="IPv4 INPUT 020 - drop invalid"
add chain=input action=drop src-address-list=HOSTS-BLOCKED comment="IPv4 INPUT 030 - HOSTS-BLOCKED"
add chain=input action=drop in-interface-list=IF-RESERVED comment="IPv4 INPUT 040 - bloqueja VLAN reservades"
add chain=input action=accept protocol=icmp comment="IPv4 INPUT 050 - ICMP"
add chain=input action=accept in-interface=bridge-LAN protocol=udp dst-port=67 comment="IPv4 INPUT 060 - DHCP MGMT"
add chain=input action=accept in-interface=vlan131-WIFI protocol=udp dst-port=67 comment="IPv4 INPUT 061 - DHCP WIFI"
add chain=input action=accept in-interface=vlan133-CTVM protocol=udp dst-port=67 comment="IPv4 INPUT 062 - DHCP CT-VM"
add chain=input action=accept src-address-list=NET-DNS-CLIENTS protocol=udp dst-port=53 comment="IPv4 INPUT 070 - DNS UDP"
add chain=input action=accept src-address-list=NET-DNS-CLIENTS protocol=tcp dst-port=53 comment="IPv4 INPUT 071 - DNS TCP"
add chain=input action=accept src-address-list=HOSTS-ALLOWED comment="IPv4 INPUT 080 - HOSTS-ALLOWED"
add chain=input action=accept src-address-list=NET-MGMT comment="IPv4 INPUT 090 - MGMT al router"
add chain=input action=drop comment="IPv4 INPUT 999 - DROP FINAL"

/ip firewall filter
add chain=forward action=drop src-address-list=HOSTS-BLOCKED comment="IPv4 FWD 010 - origen HOSTS-BLOCKED"
add chain=forward action=drop dst-address-list=HOSTS-BLOCKED comment="IPv4 FWD 011 - desti HOSTS-BLOCKED"
add chain=forward action=drop in-interface-list=IF-RESERVED comment="IPv4 FWD 020 - origen VLAN reservada"
add chain=forward action=drop out-interface-list=IF-RESERVED comment="IPv4 FWD 021 - desti VLAN reservada"
add chain=forward action=fasttrack-connection connection-state=established,related in-interface-list=IF-INTERNAL-ACTIVE out-interface-list=IF-WAN comment="IPv4 FWD 030 - FastTrack Internet"
add chain=forward action=accept connection-state=established,related,untracked comment="IPv4 FWD 040 - established related"
add chain=forward action=drop connection-state=invalid comment="IPv4 FWD 050 - drop invalid"
add chain=forward action=accept src-address-list=HOSTS-ALLOWED dst-address-list=NET-INTERNAL comment="IPv4 FWD 060 - HOSTS-ALLOWED -> internes"
add chain=forward action=accept src-address-list=NET-MGMT dst-address-list=NET-INTERNAL comment="IPv4 FWD 100 - MGMT -> VLANs"
add chain=forward action=accept src-address-list=NET-MGMT out-interface-list=IF-WAN comment="IPv4 FWD 101 - MGMT -> Internet"
add chain=forward action=accept src-address-list=NET-WIFI out-interface-list=IF-WAN comment="IPv4 FWD 200 - WIFI -> Internet"
add chain=forward action=drop src-address-list=NET-WIFI dst-address-list=NET-INTERNAL comment="IPv4 FWD 201 - WIFI X internes"
add chain=forward action=accept src-address-list=NET-PROXMOX dst-address-list=NET-CTVM comment="IPv4 FWD 300 - PROXMOX -> CT-VM"
add chain=forward action=accept src-address-list=NET-PROXMOX out-interface-list=IF-WAN comment="IPv4 FWD 301 - PROXMOX -> Internet"
add chain=forward action=accept src-address-list=NET-CTVM out-interface-list=IF-WAN comment="IPv4 FWD 400 - CT-VM -> Internet"
add chain=forward action=drop src-address-list=NET-CTVM dst-address-list=NET-PROXMOX comment="IPv4 FWD 401 - CT-VM X PROXMOX"
add chain=forward action=drop src-address-list=NET-CTVM dst-address-list=NET-MGMT comment="IPv4 FWD 402 - CT-VM X MGMT"
add chain=forward action=accept in-interface-list=IF-WAN connection-nat-state=dstnat comment="IPv4 FWD 900 - DST-NAT explicit"
add chain=forward action=drop comment="IPv4 FWD 999 - DROP FINAL"

/ipv6 settings
set disable-ipv6=no forward=yes accept-router-advertisements=no

/ipv6 dhcp-client
add interface=PPPoE-DIGI request=prefix pool-name=pool6-DIGI pool-prefix-length=64 add-default-route=yes use-peer-dns=yes disabled=no comment="DIGI DHCPv6-PD"

# Validacio real:
# /ipv6 dhcp-client print detail -> status=bound
# DIGI va delegar un /56 en la prova real.
# /ipv6 pool print detail -> pool6-DIGI amb prefix-length=64
#
# Les adreces /ipv6 address amb from-pool=pool6-DIGI consumeixen
# un /64 independent per cada interfície LAN/VLAN.

/ipv6 address
add address=::1/64 from-pool=pool6-DIGI interface=bridge-LAN advertise=yes comment="IPv6 MGMT"
add address=::1/64 from-pool=pool6-DIGI interface=vlan131-WIFI advertise=yes comment="IPv6 WIFI"
add address=::1/64 from-pool=pool6-DIGI interface=vlan132-PROXMOX advertise=yes comment="IPv6 PROXMOX"
add address=::1/64 from-pool=pool6-DIGI interface=vlan133-CTVM advertise=yes comment="IPv6 CT-VM"

/ipv6 nd
set [find where interface=all] disabled=yes
add interface=bridge-LAN advertise-dns=no managed-address-configuration=no other-configuration=no comment="RA MGMT"
add interface=vlan131-WIFI advertise-dns=no managed-address-configuration=no other-configuration=no comment="RA WIFI"
add interface=vlan132-PROXMOX advertise-dns=no managed-address-configuration=no other-configuration=no comment="RA PROXMOX"
add interface=vlan133-CTVM advertise-dns=no managed-address-configuration=no other-configuration=no comment="RA CT-VM"

/ipv6 firewall filter
add chain=input action=accept connection-state=established,related,untracked comment="IPv6 INPUT 010 - established related"
add chain=input action=drop connection-state=invalid comment="IPv6 INPUT 020 - drop invalid"
add chain=input action=drop in-interface-list=IF-RESERVED comment="IPv6 INPUT 030 - reservades"
add chain=input action=accept protocol=icmpv6 comment="IPv6 INPUT 040 - ICMPv6"
add chain=input action=accept in-interface-list=IF-WAN protocol=udp dst-port=546 comment="IPv6 INPUT 050 - DHCPv6-PD"
add chain=input action=accept in-interface-list=IF-INTERNAL-ACTIVE protocol=udp dst-port=53 comment="IPv6 INPUT 060 - DNS UDP"
add chain=input action=accept in-interface-list=IF-INTERNAL-ACTIVE protocol=tcp dst-port=53 comment="IPv6 INPUT 061 - DNS TCP"
add chain=input action=accept in-interface-list=IF-MGMT comment="IPv6 INPUT 090 - MGMT al router"
add chain=input action=drop comment="IPv6 INPUT 999 - DROP FINAL"

/ipv6 firewall filter
add chain=forward action=drop in-interface-list=IF-RESERVED comment="IPv6 FWD 010 - origen reservat"
add chain=forward action=drop out-interface-list=IF-RESERVED comment="IPv6 FWD 011 - desti reservat"
add chain=forward action=accept connection-state=established,related,untracked comment="IPv6 FWD 020 - established related"
add chain=forward action=drop connection-state=invalid comment="IPv6 FWD 030 - drop invalid"
add chain=forward action=accept protocol=icmpv6 icmp-options=1:0-255 comment="IPv6 FWD 040 - destination unreachable"
add chain=forward action=accept protocol=icmpv6 icmp-options=2:0-255 comment="IPv6 FWD 041 - packet too big"
add chain=forward action=accept protocol=icmpv6 icmp-options=3:0-255 comment="IPv6 FWD 042 - time exceeded"
add chain=forward action=accept protocol=icmpv6 icmp-options=4:0-255 comment="IPv6 FWD 043 - parameter problem"
add chain=forward action=accept in-interface-list=IF-MGMT out-interface-list=IF-INTERNAL-ACTIVE comment="IPv6 FWD 100 - MGMT -> VLANs"
add chain=forward action=accept in-interface-list=IF-MGMT out-interface-list=IF-WAN comment="IPv6 FWD 101 - MGMT -> Internet"
add chain=forward action=accept in-interface-list=IF-WIFI out-interface-list=IF-WAN comment="IPv6 FWD 200 - WIFI -> Internet"
add chain=forward action=drop in-interface-list=IF-WIFI out-interface-list=IF-INTERNAL-ACTIVE comment="IPv6 FWD 201 - WIFI X internes"
add chain=forward action=accept in-interface-list=IF-PROXMOX out-interface-list=IF-CTVM comment="IPv6 FWD 300 - PROXMOX -> CT-VM"
add chain=forward action=accept in-interface-list=IF-PROXMOX out-interface-list=IF-WAN comment="IPv6 FWD 301 - PROXMOX -> Internet"
add chain=forward action=accept in-interface-list=IF-CTVM out-interface-list=IF-WAN comment="IPv6 FWD 400 - CT-VM -> Internet"
add chain=forward action=drop in-interface-list=IF-CTVM out-interface-list=IF-PROXMOX comment="IPv6 FWD 401 - CT-VM X PROXMOX"
add chain=forward action=drop in-interface-list=IF-CTVM out-interface-list=IF-MGMT comment="IPv6 FWD 402 - CT-VM X MGMT"
add chain=forward action=drop in-interface-list=IF-WAN connection-state=new comment="IPv6 FWD 900 - bloqueja noves WAN -> LAN"
add chain=forward action=drop comment="IPv6 FWD 999 - DROP FINAL"

/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set www-ssl disabled=yes
set api disabled=yes
set api-ssl disabled=yes
set ssh address=192.168.1.0/24 disabled=no
set winbox address=192.168.1.0/24 disabled=no

/ip ssh
set strong-crypto=yes

/tool mac-server
set allowed-interface-list=none

/tool mac-server mac-winbox
set allowed-interface-list=IF-MGMT

/tool mac-server ping
set enabled=no

/ip neighbor discovery-settings
set discover-interface-list=IF-MGMT

/tool bandwidth-server
set enabled=no

/ip proxy
set enabled=no

/ip socks
set enabled=no

/ip upnp
set enabled=no

# ACTIVAR VLAN FILTERING SEMPRE AL FINAL.
/interface bridge
set bridge-LAN vlan-filtering=yes

# Comprovacions:
# /interface bridge vlan print
# /interface vlan print
# /interface pppoe-client print detail
# /ip dhcp-server lease print
# /ip firewall filter print stats
# /ipv6 dhcp-client print detail
# /ipv6 pool used print
# /ipv6 address print
# /ipv6 firewall filter print stats
