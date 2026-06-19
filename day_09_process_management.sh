#!/bin/bash
# =============================================================
#  Day 9 - Process Management
# =============================================================
#  Every running program is a process with a unique PID.
#  Processes have states: Running, Sleeping, Stopped, Zombie.
#  Parent/child relationships — init (PID 1 = systemd) is root.
#  Priority: nice value -20 (highest) to 19 (lowest), default 0
# =============================================================

# ── Viewing Processes ─────────────────────────────────────────
ps                              # Processes in current terminal
ps aux                          # All processes (all users, full info)
ps aux | grep nginx             # Filter for specific process
ps -ef                          # Full format listing
ps -ef --forest                 # Show parent/child tree
ps aux --sort=-%cpu | head -10  # Top 10 CPU consumers
ps aux --sort=-%mem | head -10  # Top 10 memory consumers
ps -u alice                     # Processes owned by alice
pstree                          # Process tree (visual)
pstree -p                       # Include PIDs

# ── top — Interactive Process Monitor ────────────────────────
top                             # Real-time process monitor
# Inside top:
#   q    = quit
#   k    = kill process (enter PID)
#   r    = renice (change priority)
#   M    = sort by memory
#   P    = sort by CPU
#   1    = show individual CPU cores
#   u    = filter by user
#   f    = field management

# ── htop — Enhanced top (install if not present) ─────────────
dnf install -y htop
htop                            # Colorful interactive process viewer

# ── Signals & Killing Processes ──────────────────────────────
kill 1234                       # Send SIGTERM (15) — graceful stop
kill -9 1234                    # Send SIGKILL — force kill (last resort)
kill -HUP 1234                  # Send SIGHUP — reload config
kill -STOP 1234                 # Pause/suspend process
kill -CONT 1234                 # Resume paused process
killall nginx                   # Kill all processes named nginx
killall -9 nginx                # Force kill all nginx
pkill nginx                     # Kill by name (pattern matching)
pkill -u alice                  # Kill all processes by user alice
pkill -f "python script.py"     # Kill by full command name

# ── Finding Process IDs ───────────────────────────────────────
pidof nginx                     # Get PID(s) of nginx
pgrep nginx                     # Similar to pidof
pgrep -l nginx                  # Include process name
pgrep -u alice                  # All PIDs owned by alice

# ── Background & Foreground Jobs ─────────────────────────────
sleep 300 &                     # Run command in background (&)
jobs                            # List background jobs
fg                              # Bring last job to foreground
fg %1                           # Bring job #1 to foreground
bg %1                           # Send job #1 to background
# Ctrl+Z  →  Suspend current foreground process
# Ctrl+C  →  Kill current foreground process

# ── nohup — Run After Logout ──────────────────────────────────
nohup ./script.sh &             # Keep running after logout
nohup ./script.sh > output.log 2>&1 &   # With custom log

# ── Process Priority (nice/renice) ────────────────────────────
nice -n 10 ./backup.sh          # Start with lower priority (10)
nice -n -5 ./critical.sh        # Start with higher priority (needs root)
renice 15 -p 1234               # Change priority of running process
renice 10 -u alice              # Change priority of all alice's processes

# ── Resource Monitoring ───────────────────────────────────────
free -h                         # Memory usage (human readable)
vmstat 2 5                      # Virtual memory stats every 2s, 5 times
iostat -x 2                     # Disk I/O stats
mpstat -P ALL 2                 # Per-CPU stats
sar -u 1 5                      # CPU utilization history
lsof                            # List open files by all processes
lsof -p 1234                    # Open files by PID
lsof -u alice                   # Open files by user
lsof -i :80                     # Which process is using port 80
lsof -i :22                     # Which process is using SSH port
