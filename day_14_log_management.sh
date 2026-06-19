#!/bin/bash
# =============================================================
#  Day 14 - Log Management in RHEL 9
# =============================================================
#  RHEL 9 uses two logging systems:
#  1. systemd-journald  — binary journal (fast, structured)
#  2. rsyslog           — traditional text-based log files
#  Both run together; journald forwards to rsyslog by default.
#  Key log directory: /var/log/
# =============================================================

# ── Key Log Files ─────────────────────────────────────────────
# /var/log/messages      — General system messages
# /var/log/secure        — Authentication & sudo logs
# /var/log/boot.log      — Boot process messages
# /var/log/cron          — Cron job logs
# /var/log/maillog       — Mail server logs
# /var/log/dnf.log       — DNF package manager logs
# /var/log/audit/audit.log — SELinux and audit logs
# /var/log/httpd/        — Apache web server logs
# /var/log/nginx/        — Nginx web server logs

# ── Basic Log Viewing ─────────────────────────────────────────
cat /var/log/messages                       # View entire file
tail /var/log/messages                      # Last 10 lines
tail -n 50 /var/log/messages                # Last 50 lines
tail -f /var/log/messages                   # Live follow (Ctrl+C to stop)
tail -f /var/log/secure                     # Watch auth events live
less /var/log/messages                      # Page through (q to quit)
grep "error" /var/log/messages              # Search for errors
grep -i "failed" /var/log/secure            # Failed auth attempts
grep "$(date +%b\ %e)" /var/log/messages    # Today's messages only

# ── journalctl — Systemd Journal ──────────────────────────────
journalctl                              # All logs
journalctl -r                           # Newest first
journalctl -f                           # Live follow (like tail -f)
journalctl -n 50                        # Last 50 entries
journalctl -u sshd                      # Logs for SSH service
journalctl -u httpd -f                  # Follow Apache logs live
journalctl -u sshd -u firewalld         # Multiple services

# Filtering by time
journalctl --since "1 hour ago"
journalctl --since "2025-01-15 08:00:00"
journalctl --since "2025-01-15" --until "2025-01-16"
journalctl --since today
journalctl --since yesterday
journalctl -b                           # Since last boot
journalctl -b -1                        # Previous boot
journalctl --list-boots                 # List all recorded boots

# Filtering by severity
journalctl -p err                       # Errors and above
journalctl -p warning                   # Warnings and above
journalctl -p 0                         # Emergency only
# Levels: 0=emerg 1=alert 2=crit 3=err 4=warning 5=notice 6=info 7=debug

# Output formats
journalctl -o json                      # JSON output
journalctl -o json-pretty               # Pretty JSON
journalctl -o short-iso                 # ISO timestamps
journalctl -o verbose                   # All fields

# By user or PID
journalctl _UID=1000                    # Logs from UID 1000
journalctl _PID=1234                    # Logs from PID 1234
journalctl _COMM=sshd                   # Logs from command 'sshd'

# Storage management
journalctl --disk-usage                 # Current journal size
journalctl --vacuum-size=500M           # Trim to 500MB
journalctl --vacuum-time=30d            # Delete older than 30 days
journalctl --vacuum-files=5             # Keep only 5 journal files

# ── rsyslog Configuration ─────────────────────────────────────
systemctl status rsyslog
cat /etc/rsyslog.conf               # Main config
ls /etc/rsyslog.d/                  # Drop-in config directory

# rsyslog rule format: FACILITY.SEVERITY   DESTINATION
# Facilities: auth, cron, daemon, kern, mail, syslog, local0-7
# Severities: emerg, alert, crit, err, warning, notice, info, debug
# Examples (add to /etc/rsyslog.d/custom.conf):
# *.err                   /var/log/errors.log      # All errors
# auth,authpriv.*         /var/log/auth.log         # Auth events
# kern.*                  /var/log/kernel.log        # Kernel messages
# *.* @192.168.1.100      # Forward to remote syslog (UDP)
# *.* @@192.168.1.100     # Forward to remote syslog (TCP)

systemctl restart rsyslog           # Apply config changes
rsyslogd -N1                        # Test config syntax

# ── logrotate — Log Rotation ──────────────────────────────────
cat /etc/logrotate.conf             # Global config
ls /etc/logrotate.d/                # Per-application rotation configs
logrotate -d /etc/logrotate.conf    # Dry run (debug mode)
logrotate -f /etc/logrotate.conf    # Force rotation now

# Example /etc/logrotate.d/myapp:
cat > /etc/logrotate.d/myapp << 'LOGROTATE'
/var/log/myapp/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    create 0644 myapp myapp
    postrotate
        systemctl reload myapp > /dev/null 2>&1 || true
    endscript
}
LOGROTATE

# ── Monitoring for Specific Events ────────────────────────────
# Watch for failed SSH logins
grep "Failed password" /var/log/secure | tail -20
grep "Failed password" /var/log/secure | awk '{print $11}' | sort | uniq -c | sort -rn

# Watch for sudo usage
grep "sudo" /var/log/secure | grep -v "session"

# Watch for service failures
journalctl -p err --since today
