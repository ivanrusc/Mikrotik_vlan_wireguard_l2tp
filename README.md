# MikroTik DIGI · VLAN · Firewall · VPN

Repositori avançat i independent de la configuració bàsica anterior.

## Plataforma

- MikroTik RB750Gr3 (hEX)
- RouterOS 7.20.7
- WAN DIGI PPPoE sobre VLAN 20
- IPv4 + IPv6 dual-stack
- Bridge VLAN Filtering
- Firewall deny-by-default entre VLANs

## Fase 1

| Xarxa | VLAN | IPv4 | DHCP | Política |
|---|---:|---|---|---|
| Management | nativa ether2 | `192.168.1.0/24` | `.100-.200` | administra totes |
| WiFi | 131 | `192.168.131.0/24` | `.100-.200` | Internet només |
| Proxmox | 132 | `192.168.132.0/24` | No | Internet + CT/VM |
| CT / VM | 133 | `192.168.133.0/24` | `.100-.200` | Internet només |
| Reservada | 134 | `192.168.134.0/24` | No | bloquejada |
| Reservada | 135 | `192.168.135.0/24` | No | bloquejada |

### Ports

- `ether1`: WAN DIGI
- `ether2`: access/untagged Management
- `ether3`, `ether4`, `ether5`: trunks VLAN 131-135

### IPs permeses i denegades

- `HOSTS-BLOCKED`: bloqueig IPv4 global
- `HOSTS-ALLOWED`: excepcions IPv4 inter-VLAN
- address-lists per cada xarxa i per accés a Internet

## IPv6

DHCPv6 Prefix Delegation sobre `PPPoE-DIGI`, amb un `/64` per Management, WiFi, Proxmox i CT/VM. No s'utilitza NAT66.

## Fase 2A — L2TP/IPsec

- Xarxa `192.168.140.0/24`
- Router `192.168.140.1`
- Pool `.100-.200`
- IPsec obligatori
- MSCHAPv2

## Fase 2B — WireGuard P2P

- local `10.255.255.1/30`
- remot `10.255.255.2/30`
- UDP `13231`

El peer queda com a plantilla fins tenir la clau pública remota i `REMOTE_LAN_CIDR`.

## Fitxers

```text
docs/
  01-Fase-1-VLAN-Firewall.html
  02-Fase-2-VPN.html

routeros/
  01-fase1-digi-vlans-firewall.rsc
  02-fase2-l2tp-ipsec.rsc
  03-fase2-wireguard-p2p-TEMPLATE.rsc
  90-exemples-address-lists.rsc

README.md
CHANGELOG.md
.gitignore
```

## Seguretat

No pugis credencials PPPoE, PSK IPsec, claus privades WireGuard ni backups `.backup` a un repositori públic.
