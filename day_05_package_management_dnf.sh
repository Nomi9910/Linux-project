#!/bin/bash
# =============================================================
#  Day 5 - Package Management with DNF (RHEL 9)
# =============================================================
#  DNF (Dandified YUM) is the default package manager in RHEL 9.
#  It replaced YUM but is fully compatible with yum commands.
#  RPM is the underlying package format (.rpm files).
#  Repos are configured in /etc/yum.repos.d/
# =============================================================

# ── Searching Packages ────────────────────────────────────────
dnf search nginx                    # Search for a package by name
dnf search all "web server"         # Search name AND description
dnf info nginx                      # Detailed info about a package
dnf list available                  # All available packages
dnf list installed                  # All installed packages
dnf list installed | grep httpd     # Check if httpd is installed
dnf provides /usr/bin/python3       # Which package owns a file
dnf provides "*/sshd"               # Find package that provides sshd

# ── Installing Packages ───────────────────────────────────────
dnf install nginx                   # Install a package
dnf install -y nginx                # Install without confirmation prompt
dnf install nginx httpd vim         # Install multiple packages
dnf install /tmp/package.rpm        # Install from local RPM file
dnf install https://example.com/p.rpm  # Install from URL

# ── Updating Packages ─────────────────────────────────────────
dnf check-update                    # List available updates
dnf update                          # Update all packages
dnf update -y                       # Update all without prompt
dnf update nginx                    # Update specific package only
dnf upgrade                         # Same as update (also handles obsoletes)

# ── Removing Packages ─────────────────────────────────────────
dnf remove nginx                    # Remove a package
dnf remove -y nginx                 # Remove without prompt
dnf autoremove                      # Remove unused dependencies

# ── Groups & Environments ─────────────────────────────────────
dnf group list                      # List available package groups
dnf group info "Development Tools"  # Info about a group
dnf group install "Development Tools"  # Install entire group
dnf group remove "Development Tools"
dnf group update "Development Tools"

# ── Repository Management ─────────────────────────────────────
dnf repolist                        # List enabled repos
dnf repolist all                    # List all repos (enabled + disabled)
dnf repoinfo baseos                 # Detailed repo info

# Enable/disable repos
dnf config-manager --enable codeready-builder-for-rhel-9-x86_64-rpms
dnf config-manager --disable epel
dnf config-manager --add-repo https://example.com/repo.repo

# Add EPEL repository (Extra Packages for Enterprise Linux)
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
dnf install -y epel-release

# ── History & Rollback ────────────────────────────────────────
dnf history                         # List all dnf transactions
dnf history info 5                  # Details of transaction #5
dnf history undo 5                  # Undo transaction #5 (rollback!)
dnf history redo 5                  # Redo transaction #5

# ── Cache Management ──────────────────────────────────────────
dnf clean all                       # Clear all cached data
dnf clean packages                  # Clear only downloaded packages
dnf makecache                       # Rebuild metadata cache

# ── RPM Commands (low-level) ──────────────────────────────────
rpm -qa                             # List ALL installed packages
rpm -qi nginx                       # Info about installed package
rpm -ql nginx                       # List all files in package
rpm -qf /usr/bin/python3            # Which package owns this file
rpm -qc nginx                       # List config files of package
rpm -ivh package.rpm                # Install RPM file (verbose)
rpm -Uvh package.rpm                # Upgrade RPM file
rpm -e nginx                        # Remove package via RPM
rpm --verify nginx                  # Verify package integrity
rpm -K package.rpm                  # Check GPG signature
