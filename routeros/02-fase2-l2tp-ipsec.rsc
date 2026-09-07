# =============================================================================
# FASE 2A - SERVIDOR L2TP/IPsec MULTIPUNT
# Requereix Fase 1.
#
# Xarxa VPN: 192.168.140.0/24
# Router:     192.168.140.1
# Pool:       192.168.140.100-192.168.140.200
#
# IMPORTANT:
# - Substituir CANVIA_AQUEST_PSK_IPSEC.
# - Crear usuaris PPP amb contrasenyes fortes i uniques.
# - Diversos clients L2TP/IPsec darrere la mateixa NAT publica poden
#   donar problemes en el mode IPsec automatic de RouterOS.
# =============================================================================

/interface list
add name=IF-VPN-L2TP comment="Interficies dinamiques L2TP"

/ip pool
add name=pool-L2TP ranges=192.168.140.100-192.168.140.200

/ppp profile
add name=profile-L2TP local-address=192.168.140.1 remote-address=pool-L2TP dns-server=192.168.140.1 change-tcp-mss=yes interface-list=IF-VPN-L2TP address-list=VPN-L2TP-USERS comment="Perfil L2TP/IPsec"

/interface l2tp-server server
set enabled=yes use-ipsec=required ipsec-secret="CANVIA_AQUEST_PSK_IPSEC" default-profile=profile-L2TP authentication=mschap2 max-mtu=1450 max-mru=1450 one-session-per-host=no

# Usuaris d'exemple DESACTIVATS:
/ppp secret
add name="vpn-user-01" password="CANVIA_CONTRASENYA_01" service=l2tp profile=profile-L2TP disabled=yes comment="EXEMPLE"
add name="vpn-user-02" password="CANVIA_CONTRASENYA_02" service=l2tp profile=profile-L2TP disabled=yes comment="EXEMPLE"

/ip firewall address-list
add list=NET-L2TP address=192.168.140.0/24 comment="VPN L2TP/IPsec"
add list=NET-INTERNAL address=192.168.140.0/24 comment="VPN L2TP"
add list=NET-INTERNET-ALLOWED address=192.168.140.0/24 comment="Permet full-tunnel"

/ip firewall filter
add chain=input action=accept in-interface-list=IF-WAN protocol=udp dst-port=500,4500 place-before=[find where comment="IPv4 INPUT 999 - DROP FINAL"] comment="L2TP 010 - IKE/NAT-T"
add chain=input action=accept in-interface-list=IF-WAN protocol=ipsec-esp place-before=[find where comment="IPv4 INPUT 999 - DROP FINAL"] comment="L2TP 020 - ESP"
add chain=input action=accept in-interface-list=IF-WAN protocol=udp dst-port=1701 ipsec-policy=in,ipsec place-before=[find where comment="IPv4 INPUT 999 - DROP FINAL"] comment="L2TP 030 - L2TP nomes dins IPsec"
add chain=input action=accept src-address=192.168.140.0/24 protocol=udp dst-port=53 place-before=[find where comment="IPv4 INPUT 999 - DROP FINAL"] comment="L2TP 040 - DNS UDP"
add chain=input action=accept src-address=192.168.140.0/24 protocol=tcp dst-port=53 place-before=[find where comment="IPv4 INPUT 999 - DROP FINAL"] comment="L2TP 041 - DNS TCP"
add chain=input action=accept src-address=192.168.140.0/24 protocol=tcp dst-port=22,8291 place-before=[find where comment="IPv4 INPUT 999 - DROP FINAL"] comment="L2TP 050 - SSH/WinBox"

/ip firewall filter
add chain=forward action=accept src-address=192.168.140.0/24 dst-address-list=NET-MGMT place-before=[find where comment="IPv4 FWD 999 - DROP FINAL"] comment="L2TP FWD 010 - VPN -> MGMT"
add chain=forward action=accept src-address=192.168.140.0/24 dst-address-list=NET-PROXMOX place-before=[find where comment="IPv4 FWD 999 - DROP FINAL"] comment="L2TP FWD 020 - VPN -> PROXMOX"
add chain=forward action=accept src-address=192.168.140.0/24 dst-address-list=NET-CTVM place-before=[find where comment="IPv4 FWD 999 - DROP FINAL"] comment="L2TP FWD 030 - VPN -> CT-VM"
add chain=forward action=accept src-address=192.168.140.0/24 out-interface-list=IF-WAN place-before=[find where comment="IPv4 FWD 999 - DROP FINAL"] comment="L2TP FWD 040 - VPN -> Internet"

/ip service
set ssh address=192.168.1.0/24,192.168.140.0/24
set winbox address=192.168.1.0/24,192.168.140.0/24

# Comprovacions:
# /interface l2tp-server server print
# /ppp active print
# /ip ipsec active-peers print
# /ip ipsec installed-sa print
# /ip firewall filter print stats
