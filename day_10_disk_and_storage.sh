#!/bin/bash
# =============================================================
#  Day 10 - Disk & Storage Management
# =============================================================
#  Linux abstracts storage as block devices (/dev/sda, /dev/nvme0n1).
#  Partitions are divided with MBR (fdisk) or GPT (gdisk/parted).
#  Filesystems: xfs (default RHEL 9), ext4, vfat, nfs
#  LVM (Logical Volume Manager) is the preferred way to manage
#  disk space flexibly in enterprise environments.
# =============================================================

# ── Disk & Partition Info ─────────────────────────────────────
lsblk                           # List block devices (tree view)
lsblk -f                        # Include filesystem type and UUID
fdisk -l                        # List all partitions (all disks)
fdisk -l /dev/sda               # Specific disk
parted -l                       # GPT partition info
blkid                           # Show UUIDs and filesystem types
df -h                           # Disk usage (human readable)
df -hT                          # Include filesystem type
du -sh /var/log                 # Size of a directory
du -sh /*                       # Size of each root-level directory
du -sh * | sort -rh | head -10  # Top 10 largest items

# ── Partitioning with fdisk (MBR) ────────────────────────────
fdisk /dev/sdb
# Inside fdisk:
#   p  — print partition table
#   n  — new partition
#   d  — delete partition
#   t  — change partition type
#   w  — write and exit
#   q  — quit without saving
#   m  — help menu

# ── Partitioning with parted (GPT) ────────────────────────────
parted /dev/sdb mklabel gpt
parted /dev/sdb mkpart primary xfs 1MiB 10GiB
parted /dev/sdb print

# ── Formatting Partitions ─────────────────────────────────────
mkfs.xfs /dev/sdb1              # Format as XFS (RHEL 9 default)
mkfs.ext4 /dev/sdb1             # Format as ext4
mkfs.vfat /dev/sdb1             # Format as FAT32
mkswap /dev/sdb2                # Format as swap

# ── Mounting & Unmounting ─────────────────────────────────────
mount /dev/sdb1 /mnt            # Temporary mount
mount -t xfs /dev/sdb1 /data    # Specify filesystem type
mount -o ro /dev/sdb1 /mnt      # Mount read-only
umount /mnt                     # Unmount (by mount point)
umount /dev/sdb1                # Unmount (by device)
mount -a                        # Mount all entries in /etc/fstab

# ── Permanent Mounting (/etc/fstab) ──────────────────────────
# Format: <device> <mountpoint> <fstype> <options> <dump> <pass>
# /dev/sdb1  /data  xfs  defaults  0  2
# UUID=xxxx  /data  xfs  defaults  0  2   ← Use UUID (preferred)

blkid /dev/sdb1                 # Get UUID first
# Add to /etc/fstab:
echo "UUID=$(blkid -s UUID -o value /dev/sdb1) /data xfs defaults 0 2" >> /etc/fstab

# ── LVM — Logical Volume Manager ─────────────────────────────
# Concept: Physical Volumes (PV) → Volume Group (VG) → Logical Volumes (LV)

# Create PV
pvcreate /dev/sdb /dev/sdc
pvs                             # Display PVs
pvdisplay                       # Detailed PV info

# Create VG
vgcreate datavg /dev/sdb /dev/sdc
vgs                             # Display VGs
vgdisplay                       # Detailed VG info

# Create LV
lvcreate -L 10G -n datalv datavg     # Fixed size
lvcreate -l 100%FREE -n datalv datavg  # Use all free space
lvs                             # Display LVs
lvdisplay                       # Detailed LV info

# Use the LV
mkfs.xfs /dev/datavg/datalv
mkdir /data
mount /dev/datavg/datalv /data

# Extend LV (online — no downtime on XFS!)
lvextend -L +5G /dev/datavg/datalv    # Add 5GB
xfs_growfs /data                       # Grow XFS filesystem
lvextend -r -L +5G /dev/datavg/datalv # Extend + resize in one step (-r)

# Extend VG (add new disk)
pvcreate /dev/sdd
vgextend datavg /dev/sdd

# ── Swap Management ───────────────────────────────────────────
swapon --show                   # Show active swap
free -h                         # Show swap usage
swapon /dev/sdb2                # Activate swap partition
swapoff /dev/sdb2               # Deactivate swap
# Add to /etc/fstab for persistence:
# /dev/sdb2  swap  swap  defaults  0  0
