#!/bin/bash
# =============================================================
#  Day 8 - SSH & Remote Access
# =============================================================
#  SSH (Secure Shell) is the standard protocol for secure
#  remote access to Linux systems. RHEL 9 uses OpenSSH.
#  Config: /etc/ssh/sshd_config (server)
#          ~/.ssh/config         (client)
#  Keys:   ~/.ssh/authorized_keys (public keys allowed to login)
# =============================================================

# ── Basic SSH Usage ───────────────────────────────────────────
ssh user@192.168.1.100              # Connect to remote host
ssh user@hostname                   # Connect by hostname
ssh -p 2222 user@host               # Custom port
ssh -i ~/.ssh/mykey user@host       # Use specific private key
ssh -v user@host                    # Verbose (debug connection issues)
ssh -X user@host                    # Enable X11 forwarding (GUI apps)
ssh -A user@host                    # Forward SSH agent

# ── SSH Key Authentication (passwordless login) ───────────────
# Step 1: Generate key pair on CLIENT machine
ssh-keygen -t ed25519 -C "alice@company.com"         # Modern (recommended)
ssh-keygen -t rsa -b 4096 -C "alice@company.com"     # RSA 4096-bit
# Creates: ~/.ssh/id_ed25519 (private) + ~/.ssh/id_ed25519.pub (public)

# Step 2: Copy public key to remote server
ssh-copy-id user@192.168.1.100                       # Automatic (easiest)
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@host       # Specific key

# Manual method (if ssh-copy-id unavailable)
cat ~/.ssh/id_ed25519.pub | ssh user@host "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# Step 3: Set correct permissions (CRITICAL)
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# ── SSH Client Config (~/.ssh/config) ────────────────────────
# Makes connecting easier with aliases
cat > ~/.ssh/config << 'SSHCONF'
Host webserver
    HostName 192.168.1.100
    User alice
    Port 22
    IdentityFile ~/.ssh/id_ed25519

Host jumpbox
    HostName 10.0.0.1
    User admin
    Port 2222

Host internal
    HostName 172.16.0.50
    User deploy
    ProxyJump jumpbox          # Tunnel through jumpbox!
SSHCONF
chmod 600 ~/.ssh/config
ssh webserver                  # Now connects using alias

# ── SSHD Server Configuration ─────────────────────────────────
# Edit: /etc/ssh/sshd_config (run as root)
# Key hardening settings:
# Port 2222                    # Change default port
# PermitRootLogin no           # Disable root SSH login
# PasswordAuthentication no    # Force key-based auth only
# PubkeyAuthentication yes     # Enable key auth
# MaxAuthTries 3               # Limit auth attempts
# ClientAliveInterval 300      # Disconnect idle sessions (5 min)
# AllowUsers alice bob         # Whitelist specific users
# AllowGroups sshusers         # Whitelist a group

systemctl restart sshd         # Apply config changes
sshd -t                        # Test config syntax before restarting

# ── SCP — Secure Copy ─────────────────────────────────────────
scp file.txt user@host:/tmp/                     # Upload file
scp user@host:/etc/hosts ./                      # Download file
scp -r mydir/ user@host:/opt/                    # Upload directory
scp -P 2222 file.txt user@host:/tmp/             # Custom port

# ── SFTP — Secure FTP ─────────────────────────────────────────
sftp user@host                 # Interactive SFTP session
# Inside SFTP: ls, cd, get, put, mget, mput, mkdir, exit

# ── SSH Tunneling / Port Forwarding ──────────────────────────
ssh -L 8080:localhost:80 user@host   # Local forward: localhost:8080 → host:80
ssh -R 9090:localhost:3000 user@host # Remote forward: host:9090 → local:3000
ssh -D 1080 user@host                # Dynamic (SOCKS proxy)

# ── SSH Agent ────────────────────────────────────────────────
eval $(ssh-agent)              # Start SSH agent
ssh-add ~/.ssh/id_ed25519      # Add key to agent (cache passphrase)
ssh-add -l                     # List loaded keys
ssh-add -D                     # Remove all keys from agent
