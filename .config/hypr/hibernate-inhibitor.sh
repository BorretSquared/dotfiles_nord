#!/bin/bash

# Optimized hibernate lock handler
# Uses systemd-inhibit for proper integration with login manager

LOG_FILE="/tmp/hibernate-inhibitor.log"

log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Clean up on exit
cleanup() {
    log_msg "Hibernate inhibitor stopped"
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT

log_msg "Starting optimized hibernate inhibitor"

# Use systemd-inhibit with delay mode - this is much faster than monitoring dbus
# The --mode=delay gives us time to lock before hibernation, but doesn't block indefinitely
exec systemd-inhibit \
    --what=sleep \
    --who="Hyprland" \
    --why="Lock screen before hibernation" \
    --mode=delay \
    bash -c '
        dbus-monitor --system "type=signal,interface=org.freedesktop.login1.Manager,member=PrepareForSleep" | \
        while read -r line; do
            if [[ "$line" == *"boolean true"* ]]; then
                # Lock immediately without waiting
                hyprlock &
                # Exit quickly - systemd will allow sleep to proceed
                exit 0
            fi
        done
    '
