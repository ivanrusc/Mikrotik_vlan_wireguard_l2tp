# CHANGELOG

## v1.0.1 — 2026-09-07

### Correcció IPv6
- Validació real amb DIGI en RB750Gr3 / RouterOS 7.20.7.
- Eliminat `allow-reconfigure=yes` per compatibilitat amb l'equip provat.
- Confirmat DHCPv6-PD `status=bound`.
- Confirmat prefix delegat `/56`.
- Confirmat `pool6-DIGI` amb `prefix-length=64`.
- Confirmat ús de `from-pool=pool6-DIGI` per generar /64 LAN/VLAN.
- Confirmada connectivitat IPv6 contra Cloudflare i Google.
- Documentació ampliada amb diagnòstic i comprovacions IPv6.

## v1.0.0 — 2026-09-07

### Fase 1
- DIGI PPPoE sobre VLAN 20
- VLAN 131 WiFi
- VLAN 132 Proxmox
- VLAN 133 CT/VM
- VLAN 134 i 135 reservades
- trunks ether3-5
- DHCP .100-.200 a MGMT, WiFi i CT/VM
- firewall IPv4/IPv6 deny-by-default
- HOSTS-ALLOWED / HOSTS-BLOCKED
- IPv6 DHCPv6-PD + SLAAC

### Fase 2
- L2TP/IPsec multipunt
- WireGuard P2P / site-to-site template
