#!/bin/bash
# =============================================================
#  Day 12 - Cron & Task Scheduling
# =============================================================
#  Cron is the standard Linux job scheduler. Jobs defined in
#  crontab files run automatically at specified times.
#  Crontab syntax: MIN HOUR DOM MON DOW COMMAND
#  MIN  = 0-59   HOUR = 0-23   DOM = 1-31 (day of month)
#  MON  = 1-12   DOW  = 0-7   (0 and 7 = Sunday)
#  Special chars: * (any)  , (list)  - (range)  / (step)
# =============================================================

# ── crontab — User Cron Jobs ──────────────────────────────────
crontab -e                      # Edit current user's crontab (uses $EDITOR)
crontab -l                      # List current user's crontab
crontab -r                      # Remove current user's crontab (careful!)
crontab -u alice -e             # Edit alice's crontab (as root)
crontab -u alice -l             # List alice's crontab (as root)

# ── Crontab Examples ──────────────────────────────────────────
# Run at 2:30 AM every day
# 30 2 * * * /usr/local/bin/backup.sh

# Run every hour
# 0 * * * * /usr/local/bin/check.sh

# Run every 15 minutes
# */15 * * * * /usr/local/bin/monitor.sh

# Run at 8 AM Mon-Fri (weekdays only)
# 0 8 * * 1-5 /usr/local/bin/report.sh

# Run on 1st of every month at midnight
# 0 0 1 * * /usr/local/bin/monthly.sh

# Run every Sunday at 3 AM
# 0 3 * * 0 /usr/local/bin/weekly-cleanup.sh

# Run at 6 AM on Jan 1 only (New Year)
# 0 6 1 1 * /usr/local/bin/newyear.sh

# Run every 5 minutes between 8 AM and 6 PM on weekdays
# */5 8-18 * * 1-5 /usr/local/bin/poll.sh

# Redirect output (always do this!)
# 30 2 * * * /usr/local/bin/backup.sh >> /var/log/backup.log 2>&1

# Suppress all output (silent)
# 30 2 * * * /usr/local/bin/backup.sh > /dev/null 2>&1

# ── Special Cron Strings ──────────────────────────────────────
# @reboot    — Run once at startup
# @yearly    — Run once a year  (0 0 1 1 *)
# @monthly   — Run once a month (0 0 1 * *)
# @weekly    — Run once a week  (0 0 * * 0)
# @daily     — Run once a day   (0 0 * * *)
# @hourly    — Run once an hour (0 * * * *)

# @reboot /usr/local/bin/startup.sh
# @daily /usr/local/bin/daily-report.sh >> /var/log/daily.log 2>&1

# ── System-wide Cron Directories ─────────────────────────────
ls /etc/cron.d/                 # Per-package cron files
ls /etc/cron.daily/             # Scripts run daily
ls /etc/cron.weekly/            # Scripts run weekly
ls /etc/cron.monthly/           # Scripts run monthly
ls /etc/cron.hourly/            # Scripts run hourly
cat /etc/crontab                # Main system crontab

# Drop script into directory for auto-scheduling:
cp /usr/local/bin/cleanup.sh /etc/cron.daily/cleanup
chmod +x /etc/cron.daily/cleanup   # Must be executable

# ── Controlling Cron Access ───────────────────────────────────
cat /etc/cron.allow             # Only listed users can use cron
cat /etc/cron.deny              # Listed users cannot use cron
# If cron.allow exists → only those users allowed
# If only cron.deny  → everyone except denied users allowed
# If neither exists  → only root can use cron (RHEL default)

# ── Systemd Timers (modern alternative to cron) ───────────────
systemctl list-timers --all     # List all systemd timers
systemctl status dnf-makecache.timer    # Example timer status

# Create a systemd timer (two files needed):
# 1) /etc/systemd/system/mybackup.service
cat > /etc/systemd/system/mybackup.service << 'UNIT'
[Unit]
Description=My Backup Job

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup.sh
UNIT

# 2) /etc/systemd/system/mybackup.timer
cat > /etc/systemd/system/mybackup.timer << 'UNIT'
[Unit]
Description=Run backup daily at 2 AM

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target
UNIT

systemctl daemon-reload
systemctl enable --now mybackup.timer
systemctl list-timers mybackup.timer

# ── at — One-time Scheduled Jobs ──────────────────────────────
dnf install -y at
systemctl enable --now atd

at now + 5 minutes              # Schedule job 5 minutes from now
at 14:30                        # Schedule at 2:30 PM today
at 9am tomorrow                 # Schedule tomorrow at 9 AM
at midnight                     # Schedule at midnight
# Type commands, then Ctrl+D to submit

atq                             # List pending at jobs
atrm 3                          # Remove job #3
