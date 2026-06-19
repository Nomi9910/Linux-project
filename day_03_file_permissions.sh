#!/bin/bash
# =============================================================
#  Day 3 - File Permissions & Ownership
# =============================================================
#  Linux uses a permission model with three categories:
#  Owner (u), Group (g), Others (o)
#  Each can have: Read (r=4), Write (w=2), Execute (x=1)
#  Example: rwxr-xr-- = 754
#  Special bits: SUID (4), SGID (2), Sticky (1)
# =============================================================

# ── Viewing Permissions ───────────────────────────────────────
ls -l /etc/passwd
# Output: -rw-r--r--  1  root  root  2847  Jan 1 10:00 /etc/passwd
#          |||||||||   |  |     |     |     |            |
#          Type+Perms  Lnk Owner Group Size Date         Name
#
# First char: - file | d directory | l symlink | b block | c char
# rwx rwx rwx = owner group others

stat /etc/hosts                 # Detailed file info including permissions

# ── chmod — Change Permissions ────────────────────────────────

# Symbolic mode
chmod u+x script.sh             # Add execute for owner
chmod g-w file.txt              # Remove write for group
chmod o+r file.txt              # Add read for others
chmod a+x script.sh             # Add execute for ALL (u+g+o)
chmod u+x,g-w,o-r file.txt      # Multiple changes at once
chmod -R 755 /var/www/html      # Recursive (all files in dir)

# Numeric (octal) mode — most common for sysadmins
# r=4, w=2, x=1  →  sum them per category
chmod 755 script.sh             # rwxr-xr-x (owner=7, group=5, others=5)
chmod 644 file.txt              # rw-r--r-- (standard for files)
chmod 600 ~/.ssh/id_rsa         # rw------- (private key — must be this!)
chmod 700 ~/.ssh                # rwx------ (SSH dir)
chmod 777 /tmp/shared           # rwxrwxrwx (full access — avoid in prod!)
chmod 000 secret.txt            # ---------- (no access for anyone)

# ── chown — Change Ownership ──────────────────────────────────
chown alice file.txt            # Change owner to alice
chown alice:developers file.txt # Change owner AND group
chown :developers file.txt      # Change group only
chown -R nginx:nginx /var/www/  # Recursive ownership change

# ── chgrp — Change Group ──────────────────────────────────────
chgrp wheel script.sh           # Change group to wheel
chgrp -R developers /opt/app/   # Recursive group change

# ── Special Permission Bits ───────────────────────────────────
# SUID (Set User ID) — runs as file owner, not executor
chmod u+s /usr/bin/program      # Symbolic
chmod 4755 /usr/bin/program     # Numeric (4 = SUID)
# Example: /usr/bin/passwd has SUID so regular users can change passwords

# SGID (Set Group ID) — new files inherit directory's group
chmod g+s /shared/dir           # Symbolic
chmod 2775 /shared/dir          # Numeric (2 = SGID)

# Sticky bit — only owner can delete their files (used on /tmp)
chmod +t /tmp                   # Symbolic
chmod 1777 /tmp                 # Numeric (1 = Sticky)
ls -ld /tmp                     # You'll see 't' at end: drwxrwxrwt

# ── umask — Default Permission Mask ──────────────────────────
umask                           # Show current umask (usually 0022)
umask 0027                      # Set umask (files=640, dirs=750)
# New file perms  = 666 - umask  →  666 - 022 = 644
# New dir perms   = 777 - umask  →  777 - 022 = 755

# ── ACL — Access Control Lists (fine-grained) ────────────────
getfacl /etc/hosts              # View ACL
setfacl -m u:alice:rw file.txt  # Give alice read+write
setfacl -m g:devs:r  file.txt   # Give group devs read
setfacl -x u:alice   file.txt   # Remove alice's ACL entry
setfacl -b           file.txt   # Remove all ACL entries
