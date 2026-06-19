#!/bin/bash
# =============================================================
#  Day 2 - Creating, Copying, Moving & Deleting Files/Dirs
# =============================================================
#  File management is one of the most fundamental sysadmin
#  skills. Learn how to create, copy, move, rename and safely
#  delete files and directories on RHEL 9.
# =============================================================

# ── Creating Files ────────────────────────────────────────────
touch file.txt                  # Create empty file (or update timestamp)
touch file1.txt file2.txt       # Create multiple files at once
echo "Hello" > file.txt         # Create file with content (overwrites)
echo "World" >> file.txt        # Append content to file
cat > notes.txt << 'HEREDOC'    # Multi-line file creation
This is line 1
This is line 2
HEREDOC

# ── Creating Directories ──────────────────────────────────────
mkdir mydir                     # Create a directory
mkdir -p /tmp/a/b/c             # Create nested directories (-p = parents)
mkdir dir1 dir2 dir3            # Create multiple directories at once

# ── Viewing File Content ──────────────────────────────────────
cat file.txt                    # Show entire file content
cat -n file.txt                 # Show with line numbers
less /var/log/messages          # Page through large files (q to quit)
more /etc/passwd                # Older pager (space to scroll)
head /etc/passwd                # Show first 10 lines
head -n 20 /etc/passwd          # Show first 20 lines
tail /var/log/messages          # Show last 10 lines
tail -n 50 /var/log/messages    # Show last 50 lines
tail -f /var/log/messages       # Follow log in real-time (Ctrl+C to stop)

# ── Copying Files & Directories ───────────────────────────────
cp file.txt backup.txt          # Copy file to new name
cp file.txt /tmp/               # Copy file to another directory
cp -i file.txt /tmp/            # Prompt before overwriting (-i = interactive)
cp -r mydir/ /tmp/mydir_copy/   # Copy directory recursively
cp -rp mydir/ /tmp/             # Preserve permissions and timestamps
cp -u file.txt /tmp/            # Copy only if source is newer

# ── Moving & Renaming ─────────────────────────────────────────
mv file.txt renamed.txt         # Rename a file
mv renamed.txt /tmp/            # Move file to another directory
mv -i file.txt /tmp/            # Prompt before overwriting
mv dir1/ /tmp/dir1_moved/       # Move a directory
mv *.txt /tmp/                  # Move all .txt files to /tmp

# ── Deleting Files & Directories ─────────────────────────────
rm file.txt                     # Delete a file
rm -i file.txt                  # Prompt before deleting (safer!)
rm -f file.txt                  # Force delete (no prompt, ignores errors)
rm *.log                        # Delete all .log files
rmdir emptydir                  # Remove empty directory only
rm -r mydir/                    # Delete directory and all contents
rm -rf mydir/                   # Force delete (use with extreme caution!)

# ── Finding Files ─────────────────────────────────────────────
find /home -name "*.txt"        # Find by name
find /var -name "*.log" -mtime -7  # Modified in last 7 days
find / -size +100M              # Files larger than 100MB
find /etc -type f -name "*.conf"   # Only files (not dirs)
find /tmp -type d               # Only directories
locate passwd                   # Fast search using database (updatedb first)
updatedb                        # Update locate database

# ── Wildcards & Globbing ──────────────────────────────────────
ls *.sh                         # All .sh files
ls file?.txt                    # file1.txt, file2.txt etc.
ls file[123].txt                # file1.txt, file2.txt, file3.txt
ls {a,b,c}.txt                  # a.txt, b.txt, c.txt
