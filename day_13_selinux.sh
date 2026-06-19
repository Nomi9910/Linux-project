#!/bin/bash
# =============================================================
#  Day 13 - SELinux (Security-Enhanced Linux)
# =============================================================
#  SELinux is a mandatory access control (MAC) system built
#  into the Linux kernel. It enforces security policies BEYOND
#  standard file permissions. Default and recommended in RHEL 9.
#  Modes: Enforcing (blocks & logs) | Permissive (logs only) | Disabled
#  Context labels: user:role:type:level (type is most important)
# =============================================================

# ── SELinux Status ────────────────────────────────────────────
getenforce                          # Current mode: Enforcing/Permissive/Disabled
sestatus                            # Detailed SELinux status
sestatus -v                         # More verbose output
cat /etc/selinux/config             # Persistent config file

# ── Changing SELinux Mode ─────────────────────────────────────
# Temporary (survives until reboot)
setenforce 0                        # Switch to Permissive (debug mode)
setenforce 1                        # Switch back to Enforcing

# Permanent (requires reboot) — edit /etc/selinux/config:
# SELINUX=enforcing   ← recommended for production
# SELINUX=permissive  ← for troubleshooting
# SELINUX=disabled    ← not recommended (requires full relabel on re-enable)

# ── SELinux Contexts ──────────────────────────────────────────
ls -Z /var/www/html                 # Show SELinux context on files
ls -Z /etc/passwd
ps -eZ | grep httpd                 # Show context on processes
id -Z                               # Show your current context

# Context format: user:role:type:level
# Example: system_u:object_r:httpd_sys_content_t:s0
# The 'type' (httpd_sys_content_t) is what matters most

# ── Changing File Contexts ────────────────────────────────────
chcon -t httpd_sys_content_t /var/www/html/index.html  # Temporary change
chcon -Rt httpd_sys_content_t /var/www/html/           # Recursive

# Permanent (survives restorecon)
semanage fcontext -a -t httpd_sys_content_t "/mywebroot(/.*)?"
restorecon -Rv /mywebroot/          # Apply the policy

# Restore default context (from policy database)
restorecon -v /etc/passwd           # Restore single file
restorecon -Rv /var/www/            # Restore directory recursively
restorecon -RFv /var/www/           # Force restore

# ── SELinux Booleans ──────────────────────────────────────────
# Booleans allow/deny specific behaviors without writing policies
getsebool -a                        # List ALL booleans
getsebool httpd_can_network_connect # Check specific boolean
setsebool httpd_can_network_connect on           # Temporary
setsebool -P httpd_can_network_connect on        # Permanent (-P)
setsebool -P httpd_enable_homedirs on            # Allow Apache to serve homedirs
setsebool -P allow_ftpd_full_access on           # Allow FTP full access
setsebool -P httpd_can_sendmail on               # Allow Apache to send mail

# Useful booleans to know:
# httpd_can_network_connect       — Apache can connect to network
# httpd_can_connect_db            — Apache can connect to database
# httpd_enable_cgi                — Apache can run CGI scripts
# ftp_home_dir                    — FTP can access home dirs
# samba_enable_home_dirs          — Samba can share home dirs
# ssh_sysadm_login                — SSH sysadmin login

# ── SELinux Troubleshooting ───────────────────────────────────
dnf install -y setroubleshoot-server audit
sealert -a /var/log/audit/audit.log     # Analyze and explain denials
ausearch -m avc -ts recent              # Recent AVC denials
ausearch -m avc -c httpd                # Denials for httpd
audit2why < /var/log/audit/audit.log    # Explain why access was denied
audit2allow -a                          # Generate allow rules from denials
audit2allow -a -M mypolicy             # Create custom policy module
semodule -i mypolicy.pp                 # Install custom policy module
semodule -l                             # List all installed modules

# Typical troubleshooting workflow:
# 1. setenforce 0           → switch to permissive
# 2. Test your application  → reproduce the issue
# 3. ausearch -m avc -ts recent   → find denials
# 4. sealert -a /var/log/audit/audit.log  → get fix suggestions
# 5. Apply fix (boolean or context change)
# 6. setenforce 1           → back to enforcing
# 7. Test again

# ── Port Contexts ─────────────────────────────────────────────
semanage port -l                        # List all port contexts
semanage port -l | grep http            # Filter for http
semanage port -a -t http_port_t -p tcp 8080   # Allow Apache on port 8080
semanage port -d -t http_port_t -p tcp 8080   # Remove it
