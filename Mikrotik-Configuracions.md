

### Paquet complet

[📦 Descarregar MikroTik-DIGI-VLAN-VPN v1.0] - zip

També tens els fitxers principals per separat:

[📘 Manual HTML — Fase 1 VLAN + Firewall] - html

[📘 Manual HTML — Fase 2 VPN] - html

[⚙️ RouterOS — Fase 1] - rsc

[🔐 RouterOS — L2TP/IPsec] - rsc

[🔗 RouterOS — WireGuard P2P plantilla] - rsc

[🛡️ Exemples IPs permeses/denegades] - rsc

### Estructura

```text
MikroTik-DIGI-VLAN-VPN/
├── README.md
├── CHANGELOG.md
├── .gitignore
│
├── docs/
│   ├── 01-Fase-1-VLAN-Firewall.html
│   └── 02-Fase-2-VPN.html
│
└── routeros/
    ├── 01-fase1-digi-vlans-firewall.rsc
    ├── 02-fase2-l2tp-ipsec.rsc
    ├── 03-fase2-wireguard-p2p-TEMPLATE.rsc
    └── 90-exemples-address-lists.rsc
```

La configuració implementa exactament la matriu acordada: MGMT pot administrar les VLAN, WiFi només surt a Internet, Proxmox pot arribar a CT/VM, CT/VM no pot iniciar cap a Proxmox/MGMT, i VLAN134/135 queden bloquejades. Els trunks `ether3-5` accepten només trànsit tagged i `vlan-filtering=yes` s'activa al final, que és l'ordre segur recomanat per MikroTik. ([MikroTik Help][1])

Per IPv6 utilitza DHCPv6-PD i assigna `/64` independents a MGMT, WiFi, Proxmox i CT/VM, sense NAT66. RouterOS suporta directament l'ús del prefix delegat mitjançant `from-pool` i Router Advertisements. ([MikroTik Help][2])

Per la Fase 2 he reservat:

```text
L2TP/IPsec
192.168.140.0/24
Gateway VPN: 192.168.140.1
Clients:     192.168.140.100-200

WireGuard P2P
10.255.255.0/30
MikroTik:    10.255.255.1
Remot:       10.255.255.2
Port:        UDP 13231
```

L2TP està configurat amb `use-ipsec=required` i UDP 1701 només s'accepta quan el paquet coincideix amb una política IPsec. MikroTik documenta una limitació important: diversos clients L2TP/IPsec darrere de **la mateixa NAT pública** poden no funcionar amb el mode IPsec automàtic; en aquests casos WireGuard és preferible. ([MikroTik Help][3])

El WireGuard està expressament com a **template**, perquè encara ens falten dues dades de l'altre extrem:

```text
CLAU_PUBLICA_REMOTA_BASE64
REMOTE_LAN_CIDR
```

La configuració segueix el model P2P/site-to-site oficial de MikroTik amb xarxa de trànsit `/30`, `allowed-address` i ruta cap a la LAN remota. ([MikroTik Help][4])

Per al nou GitHub jo utilitzaria com a nom:

```text
MikroTik-DIGI-VLAN-VPN
```

