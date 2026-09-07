# =============================================================================
# FASE 2B - WIREGUARD P2P / SITE-TO-SITE
# Requereix Fase 1.
#
# Link:
#   local  10.255.255.1/30
#   remot  10.255.255.2/30
#   UDP    13231
#
# ABANS DE CREAR EL PEER:
# - obtenir CLAU_PUBLICA_REMOTA_BASE64
# - definir REMOTE_LAN_CIDR
# =============================================================================

/interface wireguard
add name=WG-P2P listen-port=13231 mtu=1420 comment="WireGuard P2P"

/ip address
add address=10.255.255.1/30 interface=WG-P2P comment="WireGuard link local"

/interface list
add name=IF-VPN-WG comment="WireGuard site-to-site"

/interface list member
add list=IF-VPN-WG interface=WG-P2P

# PEER REMOT - DESCOMENTAR I EDITAR:
#
# /interface wireguard peers
# add interface=WG-P2P \
#     public-key="CLAU_PUBLICA_REMOTA_BASE64" \
#     allowed-address=10.255.255.2/32,REMOTE_LAN_CIDR \
#     persistent-keepalive=25s \
#     comment="Seu remota"
#
# RUTA REMOTA:
# /ip route
# add dst-address=REMOTE_LAN_CIDR gateway=WG-P2P comment="LAN remota via WireGuard"

/ip firewall address-list
add list=NET-WG-LINK address=10.255.255.0/30 comment="Link WireGuard P2P"

/ip firewall filter
add chain=input action=accept in-interface-list=IF-WAN protocol=udp dst-port=13231 place-before=[find where comment="IPv4 INPUT 999 - DROP FINAL"] comment="WG 010 - handshake UDP 13231"
add chain=input action=accept in-interface=WG-P2P protocol=icmp place-before=[find where comment="IPv4 INPUT 999 - DROP FINAL"] comment="WG 020 - ICMP link"
add chain=input action=accept in-interface=WG-P2P protocol=tcp dst-port=22,8291 place-before=[find where comment="IPv4 INPUT 999 - DROP FINAL"] comment="WG 030 - SSH/WinBox des del peer"

/ip firewall filter
add chain=forward action=accept in-interface=WG-P2P dst-address-list=NET-MGMT place-before=[find where comment="IPv4 FWD 999 - DROP FINAL"] comment="WG FWD 010 - remot -> MGMT"
add chain=forward action=accept in-interface=WG-P2P dst-address-list=NET-PROXMOX place-before=[find where comment="IPv4 FWD 999 - DROP FINAL"] comment="WG FWD 020 - remot -> PROXMOX"
add chain=forward action=accept in-interface=WG-P2P dst-address-list=NET-CTVM place-before=[find where comment="IPv4 FWD 999 - DROP FINAL"] comment="WG FWD 030 - remot -> CT-VM"
add chain=forward action=accept src-address-list=NET-MGMT out-interface=WG-P2P place-before=[find where comment="IPv4 FWD 999 - DROP FINAL"] comment="WG FWD 040 - MGMT -> remot"
add chain=forward action=accept src-address-list=NET-PROXMOX out-interface=WG-P2P place-before=[find where comment="IPv4 FWD 999 - DROP FINAL"] comment="WG FWD 050 - PROXMOX -> remot"
add chain=forward action=accept src-address-list=NET-CTVM out-interface=WG-P2P place-before=[find where comment="IPv4 FWD 999 - DROP FINAL"] comment="WG FWD 060 - CT-VM -> remot"

/ip service
set ssh address=192.168.1.0/24,192.168.140.0/24,10.255.255.0/30
set winbox address=192.168.1.0/24,192.168.140.0/24,10.255.255.0/30

# Comprovacions:
# /interface wireguard print detail
# /interface wireguard peers print detail
# /ping 10.255.255.2
# /ip route print
# /ip firewall filter print stats
