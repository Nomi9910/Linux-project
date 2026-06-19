#!/bin/bash
# =============================================================
#  Day 15 - Shell Scripting Basics (Bash)
# =============================================================
#  Shell scripts automate repetitive tasks. A script is just a
#  text file with commands, starting with a shebang (#!/bin/bash).
#  Best practices: always quote variables, check exit codes,
#  use functions, log output, handle errors.
# =============================================================

# ── Script Setup Best Practices ───────────────────────────────
#!/bin/bash
set -euo pipefail               # e=exit on error, u=undefined vars, o pipefail
# set -x                        # Debug mode (print each command)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/myscript.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

log() { echo "[$TIMESTAMP] $*" | tee -a "$LOG_FILE"; }
log "Script started"

# ── Variables ─────────────────────────────────────────────────
NAME="RHEL9"
VERSION=9
GREETING="Hello, $NAME $VERSION!"
echo "$GREETING"

CURRENT_USER=$(whoami)          # Command substitution
HOSTNAME_VAR=$(hostname)
echo "Running as $CURRENT_USER on $HOSTNAME_VAR"

readonly CONSTANT="unchangeable" # Read-only variable
LOCAL_VAR="${NAME:-default}"     # Use 'default' if NAME is unset

# ── User Input ────────────────────────────────────────────────
read -p "Enter your name: " USER_NAME
read -sp "Enter password: " USER_PASS   # -s = silent (no echo)
echo
echo "Hello, $USER_NAME!"

# ── Conditionals ──────────────────────────────────────────────
AGE=20

if [ "$AGE" -ge 18 ]; then
    echo "Adult"
elif [ "$AGE" -ge 13 ]; then
    echo "Teenager"
else
    echo "Child"
fi

# File tests
FILE="/etc/passwd"
if [ -f "$FILE" ]; then echo "$FILE exists and is a file"; fi
if [ -d "/etc" ]; then echo "/etc is a directory"; fi
if [ -r "$FILE" ]; then echo "$FILE is readable"; fi
if [ -s "$FILE" ]; then echo "$FILE is not empty"; fi
if [ ! -e "/tmp/missing" ]; then echo "File does not exist"; fi

# String tests
if [ -z "$NAME" ]; then echo "NAME is empty"; fi
if [ -n "$NAME" ]; then echo "NAME is not empty"; fi
if [ "$NAME" = "RHEL9" ]; then echo "Name matches"; fi

# ── Loops ─────────────────────────────────────────────────────
# for loop
for i in 1 2 3 4 5; do
    echo "Number: $i"
done

for file in /etc/*.conf; do
    echo "Config: $file"
done

for i in $(seq 1 5); do
    echo "Seq: $i"
done

# C-style for
for ((i=0; i<5; i++)); do
    echo "Index: $i"
done

# while loop
COUNT=0
while [ $COUNT -lt 5 ]; do
    echo "Count: $COUNT"
    ((COUNT++))
done

# ── Functions ─────────────────────────────────────────────────
greet() {
    local name="$1"             # Local variable
    local greeting="${2:-Hello}" # Default parameter
    echo "$greeting, $name!"
}

greet "Alice"
greet "Bob" "Hi"

check_service() {
    local service="$1"
    if systemctl is-active --quiet "$service"; then
        echo "$service is running"
        return 0
    else
        echo "$service is NOT running"
        return 1
    fi
}

check_service sshd || echo "WARNING: SSH is down!"

# ── Exit Codes & Error Handling ───────────────────────────────
# Every command returns 0 (success) or non-zero (failure)
ls /etc/passwd
echo "Exit code: $?"            # $? holds last exit code

command_that_might_fail || { echo "Command failed!"; exit 1; }

# Trap — cleanup on exit or error
cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/myscript_lockfile
}
trap cleanup EXIT               # Run cleanup() when script exits
trap 'echo "Error on line $LINENO"' ERR   # On any error

# ── Script Arguments ──────────────────────────────────────────
# $0 = script name
# $1, $2, ... = positional arguments
# $# = number of arguments
# $@ = all arguments (each quoted separately)
# $* = all arguments (as single string)

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

echo "Script: $0"
echo "First arg: $1"
echo "All args: $@"
echo "Arg count: $#"

# ── Practical Example: Backup Script ─────────────────────────
backup_dir() {
    local src="$1"
    local dest="/backup/$(basename "$src")-$(date +%Y%m%d-%H%M%S).tar.gz"

    if [ ! -d "$src" ]; then
        echo "ERROR: Source directory $src does not exist"
        return 1
    fi

    mkdir -p /backup
    tar -czf "$dest" "$src" && echo "Backup saved: $dest" || echo "Backup FAILED"
}

# backup_dir /etc
# backup_dir /home
