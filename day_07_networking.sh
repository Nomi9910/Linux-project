#!/bin/bash
# =============================================================
#  Day 7 - Networking in RHEL 9
# =============================================================
#  RHEL 9 uses NetworkManager as the primary network manager.
#  nmcli is the command-line interface for NetworkManager.
#  Config files live in: /etc/NetworkManager/system-connections/
#  Legacy /etc/sysconfig/network-scripts/ still works but deprecated.
# =============================================================

# ── Network Status ────────────────────────────────────────────
ip addr                         # Show all interfaces and IPs (replaces ifconfig)
ip addr show eth0               # Show specific interface
ip -br addr                     # Brief/compact view
ip link show                    # Show link layer info
ip route                        # Show routing table
ip route show default           # Show default gateway
ip neigh                        # Show ARP table (neighbor cache)
ss -tuln                        # Show listening ports (replaces netstat)
ss -tulnp                       # Include process info
ss -s                           # Socket statistics summary

# ── nmcli — NetworkManager CLI ───────────────────────────────
nmcli general status            # Overall NetworkManager status
nmcli device status             # All network devices and state
nmcli connection show           # List all connections
nmcli connection show --active  # Only active connections
nmcli device show eth0          # Detailed info on eth0

# Configure static IP
nmcli connection modify eth0 \
  ipv4.method manual \
  ipv4.addresses "192.168.1.100/24" \
  ipv4.gateway "192.168.1.1" \
  ipv4.dns "8.8.8.8 8.8.4.4"
nmcli connection up eth0        # Activate the connection

# Configure DHCP
nmcli connection modify eth0 ipv4.method auto
nmcli connection up eth0

# Add a new connection
nmcli connection add type ethernet con-name "office" ifname eth0 \
  ipv4.method manual ipv4.addresses 10.0.0.50/24 ipv4.gateway 10.0.0.1
nmcli connection delete office  # Delete a connection

# Bring interface up/down
nmcli connection up eth0
nmcli connection down eth0
nmcli device disconnect eth0
nmcli device connect eth0

# ── DNS Configuration ─────────────────────────────────────────
cat /etc/resolv.conf            # View DNS servers
hostnamectl                     # View/set hostname
hostnamectl set-hostname rhel9-server  # Set hostname permanently
cat /etc/hosts                  # Local hostname resolution
# Add entry: 192.168.1.50  myserver.local myserver

# ── Connectivity Testing ──────────────────────────────────────
ping -c 4 google.com            # Test connectivity (4 packets)
ping -c 4 8.8.8.8               # Ping by IP
traceroute google.com           # Trace network path
tracepath google.com            # Similar (no root required)
mtr google.com                  # Live traceroute (combine ping+traceroute)
dig google.com                  # DNS lookup (detailed)
dig google.com A                # Query specific record type
dig @8.8.8.8 google.com         # Use specific DNS server
nslookup google.com             # Simple DNS lookup
host google.com                 # Another DNS lookup tool
curl -I https://google.com      # Test HTTP connectivity
wget -q --spider https://google.com  # Test URL accessibility
nc -zv 192.168.1.1 22           # Test if port is open (netcat)

# ── Firewall (firewalld) ──────────────────────────────────────
systemctl status firewalld
firewall-cmd --state
firewall-cmd --get-active-zones
firewall-cmd --zone=public --list-all
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload
firewall-cmd --zone=public --remove-service=http --permanent
