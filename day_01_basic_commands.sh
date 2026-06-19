#!/bin/bash
# =============================================================
#  Day 1 - Basic Linux Commands (Red Hat 9)
# =============================================================
#  These are the most essential commands every Linux sysadmin
#  uses daily. Master these before anything else.
#  All examples assume you are logged in as a regular user
#  or root on a RHEL 9 system.
# =============================================================

# ── Navigation ────────────────────────────────────────────────
pwd                        # Print current working directory
ls                         # List files in current directory
ls -l                      # Long listing (permissions, size, date)
ls -la                     # Include hidden files (starting with .)
ls -lh                     # Human-readable file sizes (KB, MB, GB)
ls -lt                     # Sort by modification time (newest first)
ls /etc                    # List contents of a specific directory

cd /etc                    # Change to /etc directory
cd ~                       # Go to your home directory
cd ..                      # Go up one level
cd -                       # Return to previous directory
cd /var/log                # Absolute path navigation

# ── System Information ────────────────────────────────────────
whoami                     # Show current logged-in user
hostname                   # Show system hostname
hostname -I                # Show all IP addresses
uname -a                   # Full kernel and system info
uname -r                   # Kernel version only
uptime                     # How long system has been running
date                       # Current date and time
date "+%Y-%m-%d %H:%M:%S"  # Formatted date/time
cal                        # Calendar for current month
timedatectl                # Show timezone and NTP sync status

# ── Help & Documentation ──────────────────────────────────────
man ls                     # Manual page for 'ls' command
man -k network             # Search man pages by keyword
ls --help                  # Quick help for a command
info coreutils             # GNU info documentation
whatis ls                  # One-line description of command
which python3              # Show full path of a command
whereis bash               # Find binary, source, and man page

# ── Clearing & History ────────────────────────────────────────
clear                      # Clear the terminal screen (Ctrl+L)
history                    # Show command history
history | grep ssh         # Search command history
!42                        # Re-run command number 42 from history
!!                         # Re-run last command
echo "Hello, RHEL 9!"     # Print text to screen

# ── Shutdown / Reboot ─────────────────────────────────────────
# systemctl reboot         # Reboot the system
# systemctl poweroff       # Shut down the system
# shutdown -h +5           # Shutdown in 5 minutes with warning
# shutdown -r now          # Reboot immediately
