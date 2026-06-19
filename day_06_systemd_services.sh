#!/bin/bash
# =============================================================
#  Day 6 - Systemd & Service Management
# =============================================================
#  Systemd is the init system and service manager in RHEL 9.
#  It replaces the old SysV init scripts.
#  Unit files live in: /usr/lib/systemd/system/ (system)
#                      /etc/systemd/system/      (custom/overrides)
#  Target = runlevel equivalent (multi-user, graphical, etc.)
# =============================================================

# ── Service Control (systemctl) ───────────────────────────────
systemctl start nginx           # Start a service
systemctl stop nginx            # Stop a service
systemctl restart nginx         # Stop then start
systemctl reload nginx          # Reload config without stopping
systemctl status nginx          # Show service status + recent logs
systemctl enable nginx          # Enable at boot
systemctl disable nginx         # Disable at boot
systemctl enable --now nginx    # Enable AND start immediately
systemctl disable --now nginx   # Disable AND stop immediately
systemctl is-active nginx       # Returns 'active' or 'inactive'
systemctl is-enabled nginx      # Returns 'enabled' or 'disabled'
systemctl is-failed nginx       # Check if service has failed

# ── Listing Services ──────────────────────────────────────────
systemctl list-units --type=service             # All active services
systemctl list-units --type=service --all       # Including inactive
systemctl list-unit-files --type=service        # All + enabled/disabled state
systemctl list-units --failed                   # Show failed units

# ── Masking (stronger than disable) ──────────────────────────
systemctl mask nginx            # Prevent service from EVER starting
systemctl unmask nginx          # Re-allow the service

# ── System Targets (Runlevels) ────────────────────────────────
# Old runlevel  →  Systemd target
# 0             →  poweroff.target
# 1             →  rescue.target
# 3             →  multi-user.target  (CLI only)
# 5             →  graphical.target   (GUI)
# 6             →  reboot.target

systemctl get-default                           # Show default target
systemctl set-default multi-user.target         # Set default to CLI
systemctl set-default graphical.target          # Set default to GUI
systemctl isolate rescue.target                 # Switch to rescue mode NOW
systemctl isolate multi-user.target             # Switch to multi-user NOW

# ── Journald — Systemd Logging ────────────────────────────────
journalctl                              # All logs (oldest first)
journalctl -r                           # Reverse (newest first)
journalctl -f                           # Follow live (like tail -f)
journalctl -u nginx                     # Logs for specific service
journalctl -u nginx -f                  # Follow nginx logs live
journalctl -u nginx --since "1 hour ago"
journalctl -u nginx --since "2025-01-01" --until "2025-01-02"
journalctl -p err                       # Only error-level and above
journalctl -p warning..crit             # Severity range
journalctl --since today                # Today's logs only
journalctl -b                           # Logs since last boot
journalctl -b -1                        # Logs from previous boot
journalctl --disk-usage                 # How much space logs use
journalctl --vacuum-size=500M           # Clean logs to under 500MB
journalctl --vacuum-time=30d            # Delete logs older than 30 days

# ── Creating a Custom Service ─────────────────────────────────
# Create unit file: /etc/systemd/system/myapp.service
cat > /etc/systemd/system/myapp.service << 'UNIT'
[Unit]
Description=My Custom Application
After=network.target

[Service]
Type=simple
User=myapp
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/start.sh
ExecStop=/opt/myapp/stop.sh
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload                 # Reload after creating/editing unit
systemctl enable --now myapp            # Enable and start
