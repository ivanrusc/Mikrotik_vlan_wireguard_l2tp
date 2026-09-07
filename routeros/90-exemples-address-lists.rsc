# =============================================================================
# EXEMPLES - IPs PERMESES I DENEGADES
# No executar cegament: copiar i adaptar.
# =============================================================================

# Bloquejar una IP interna:
# /ip firewall address-list add list=HOSTS-BLOCKED address=192.168.131.50 comment="Equip bloquejat"

# Eliminar bloqueig:
# /ip firewall address-list remove [find where list=HOSTS-BLOCKED and address=192.168.131.50]

# Excepcio inter-VLAN:
# /ip firewall address-list add list=HOSTS-ALLOWED address=192.168.133.10 comment="CT autoritzat"

# Eliminar excepcio:
# /ip firewall address-list remove [find where list=HOSTS-ALLOWED and address=192.168.133.10]

# Consultar:
# /ip firewall address-list print where list=HOSTS-BLOCKED
# /ip firewall address-list print where list=HOSTS-ALLOWED

# Si una IP acabada de bloquejar tenia connexions establertes/FastTrack,
# revisar i eliminar-ne les connexions existents:
# /ip firewall connection print where src-address~"192.168.131.50"
# /ip firewall connection remove [find where src-address~"192.168.131.50"]
