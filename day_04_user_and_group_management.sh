#!/bin/bash
# =============================================================
#  Day 4 - User & Group Management
# =============================================================
#  Every process and file in Linux is owned by a user and group.
#  Key files:
#    /etc/passwd   — user accounts
#    /etc/shadow   — encrypted passwords
#    /etc/group    — group definitions
#    /etc/sudoers  — sudo privileges (edit with visudo!)
# =============================================================

# ── User Information ──────────────────────────────────────────
whoami                          # Current user
id                              # UID, GID, and all groups
id alice                        # Info for another user
who                             # Who is logged in
w                               # Who is logged in + what they're doing
last                            # Login history
lastlog                         # Last login for all users
finger alice                    # User info (if finger is installed)
cat /etc/passwd                 # View all user accounts
# Format: username:x:UID:GID:comment:home:shell
getent passwd alice             # Query user from any source (local/LDAP)

# ── Creating Users ────────────────────────────────────────────
useradd alice                            # Create user (defaults)
useradd -m alice                         # Create with home directory
useradd -m -s /bin/bash alice            # Specify shell
useradd -m -u 1500 -g developers alice   # Set UID and primary group
useradd -m -c "Alice Smith" alice        # Add comment/full name
useradd -m -e 2025-12-31 alice           # Set account expiry date
useradd -r svcaccount                    # Create system account (no home, no login)

# ── Setting & Changing Passwords ─────────────────────────────
passwd alice                    # Set/change alice's password (interactive)
echo "SecurePass123!" | passwd --stdin alice  # Non-interactive (scripts)
passwd -l alice                 # Lock account (disable password)
passwd -u alice                 # Unlock account
passwd -e alice                 # Force password change on next login
chage -l alice                  # Show password aging info
chage -M 90 alice               # Password expires every 90 days
chage -W 7  alice               # Warn 7 days before expiry

# ── Modifying Users ───────────────────────────────────────────
usermod -s /bin/zsh alice       # Change shell
usermod -d /data/alice alice    # Change home directory
usermod -l newname alice        # Rename user login
usermod -L alice                # Lock user account
usermod -U alice                # Unlock user account
usermod -aG wheel alice         # Add to supplementary group (wheel=sudo)
usermod -aG docker,developers alice  # Add to multiple groups
usermod -e 2026-06-30 alice     # Set account expiry

# ── Deleting Users ────────────────────────────────────────────
userdel alice                   # Delete user (keeps home dir)
userdel -r alice                # Delete user AND home directory
userdel -f alice                # Force delete even if user is logged in

# ── Group Management ──────────────────────────────────────────
cat /etc/group                  # View all groups
groupadd developers             # Create a group
groupadd -g 2000 devops         # Create group with specific GID
groupmod -n engineering developers  # Rename group
groupdel developers             # Delete a group
gpasswd -a alice developers     # Add user to group
gpasswd -d alice developers     # Remove user from group
gpasswd -A alice developers     # Make alice group admin
newgrp developers               # Switch primary group in current session

# ── Sudo Configuration ────────────────────────────────────────
visudo                          # ALWAYS use this to edit /etc/sudoers safely
# Add to /etc/sudoers:
#   alice ALL=(ALL) ALL           — full sudo access
#   alice ALL=(ALL) NOPASSWD: ALL — sudo without password
#   %wheel ALL=(ALL) ALL          — all members of wheel group
#   alice ALL=(ALL) /usr/bin/systemctl  — only specific command

# Drop a file in /etc/sudoers.d/ (preferred method):
echo "alice ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/alice
chmod 440 /etc/sudoers.d/alice
