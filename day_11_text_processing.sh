#!/bin/bash
# =============================================================
#  Day 11 - Text Processing (grep, sed, awk, cut, sort, uniq)
# =============================================================
#  Linux has powerful text-processing tools that sysadmins use
#  daily to search, filter, transform, and analyze log files
#  and configuration files. These tools follow the Unix
#  philosophy: do one thing well and chain with pipes (|).
# =============================================================

# ── grep — Search for patterns ────────────────────────────────
grep "error" /var/log/messages          # Basic search
grep -i "error" /var/log/messages       # Case-insensitive
grep -n "error" /var/log/messages       # Show line numbers
grep -c "error" /var/log/messages       # Count matching lines
grep -v "debug" /var/log/messages       # Invert match (exclude)
grep -r "password" /etc/               # Recursive search in directory
grep -l "error" /var/log/*.log          # Only show filenames
grep -w "root" /etc/passwd              # Match whole word only
grep -A 3 "error" /var/log/messages    # 3 lines AFTER match
grep -B 3 "error" /var/log/messages    # 3 lines BEFORE match
grep -C 3 "error" /var/log/messages    # 3 lines AROUND match
grep -E "error|warn|crit" /var/log/messages  # Extended regex (multiple)
grep "^root" /etc/passwd               # Lines starting with 'root'
grep "bash$" /etc/passwd               # Lines ending with 'bash'
grep "[0-9]\{3\}" file.txt             # Lines with 3 consecutive digits

# ── sed — Stream Editor ───────────────────────────────────────
sed 's/old/new/' file.txt              # Replace first occurrence per line
sed 's/old/new/g' file.txt             # Replace ALL occurrences (global)
sed 's/old/new/gi' file.txt            # Case-insensitive replace
sed -i 's/old/new/g' file.txt          # Edit file IN PLACE
sed -i.bak 's/old/new/g' file.txt      # In-place with backup (.bak)
sed -n '5p' file.txt                   # Print only line 5
sed -n '5,10p' file.txt                # Print lines 5 to 10
sed '5d' file.txt                      # Delete line 5
sed '/pattern/d' file.txt             # Delete lines matching pattern
sed '/^#/d' /etc/ssh/sshd_config       # Remove comment lines
sed '/^$/d' file.txt                   # Remove blank lines
sed '1i\# Header line' file.txt        # Insert line before line 1
sed '$a\# Footer line' file.txt        # Append line after last line
sed -n '/START/,/END/p' file.txt       # Print between START and END

# ── awk — Pattern & Text Processing ──────────────────────────
awk '{print}' file.txt                 # Print all lines
awk '{print $1}' file.txt              # Print first field
awk '{print $1, $3}' file.txt          # Print 1st and 3rd fields
awk '{print NR, $0}' file.txt          # Print with line numbers (NR)
awk '{print NF}' file.txt              # Print number of fields per line
awk -F: '{print $1}' /etc/passwd       # Custom delimiter (colon)
awk -F: '{print $1, $7}' /etc/passwd   # Username and shell
awk -F: '$3 >= 1000 {print $1}' /etc/passwd  # Users with UID >= 1000
awk '/error/ {print}' /var/log/messages       # Print matching lines
awk '{sum += $1} END {print sum}' nums.txt     # Sum a column
awk 'NR==5' file.txt                   # Print only line 5
awk 'NR>=5 && NR<=10' file.txt         # Print lines 5-10
awk '{if ($3 > 100) print $1}' file.txt        # Conditional printing

# ── cut — Extract columns ─────────────────────────────────────
cut -d: -f1 /etc/passwd                # Field 1 using : delimiter
cut -d: -f1,3 /etc/passwd              # Fields 1 and 3
cut -d, -f2 data.csv                   # Field 2 from CSV
cut -c1-10 file.txt                    # Characters 1 to 10

# ── sort & uniq ───────────────────────────────────────────────
sort file.txt                          # Alphabetical sort
sort -r file.txt                       # Reverse sort
sort -n numbers.txt                    # Numeric sort
sort -k2 file.txt                      # Sort by 2nd field
sort -t: -k3 -n /etc/passwd            # Sort passwd by UID
sort -u file.txt                       # Sort and remove duplicates
sort file.txt | uniq                   # Remove consecutive duplicates
sort file.txt | uniq -c                # Count occurrences
sort file.txt | uniq -d                # Show only duplicates

# ── tr — Translate/delete characters ─────────────────────────
echo "hello" | tr 'a-z' 'A-Z'         # Lowercase to uppercase
echo "Hello World" | tr -d 'aeiou'    # Delete vowels
echo "hello   world" | tr -s ' '      # Squeeze multiple spaces to one

# ── wc — Word/Line/Char Count ─────────────────────────────────
wc -l /etc/passwd                      # Count lines
wc -w file.txt                         # Count words
wc -c file.txt                         # Count bytes
cat /var/log/messages | grep error | wc -l  # Count error lines
