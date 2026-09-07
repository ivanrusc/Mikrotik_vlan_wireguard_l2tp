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


## Validació IPv6 — RouterOS 7.20.7

Configuració validada en un **MikroTik RB750Gr3** amb **RouterOS 7.20.7**.

DHCPv6-PD funcional:

```routeros
/ipv6 dhcp-client
add interface=PPPoE-DIGI request=prefix pool-name=pool6-DIGI pool-prefix-length=64 add-default-route=yes use-peer-dns=yes disabled=no comment="DIGI DHCPv6-PD"
```

En la prova real:

- DHCPv6 client: `status=bound`
- DIGI: prefix delegat `/56`
- `pool6-DIGI`: `prefix-length=64`
- IPv6 global creada amb `from-pool=pool6-DIGI`
- Ping IPv6 a Cloudflare: `0% packet-loss`
- Ping IPv6 a Google: `0% packet-loss`

Per assignar un `/64` a una LAN:

```routeros
/ipv6 address
add address=::1/64 from-pool=pool6-DIGI interface=bridge-LAN advertise=yes comment="IPv6 MGMT"
```

### Compatibilitat `allow-reconfigure`

La versió del projecte **v1.0.1 no utilitza `allow-reconfigure=yes`**. En el RB750Gr3 provat amb RouterOS 7.20.7 el CLI va rebutjar aquest paràmetre. No és necessari per obtenir el prefix DHCPv6-PD.

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
