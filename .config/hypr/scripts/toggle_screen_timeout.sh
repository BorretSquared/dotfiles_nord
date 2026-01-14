#!/bin/bash

# Toggle screen timeout by managing hypridle service
# This script starts/stops hypridle and provides a notification

STATE_FILE="$HOME/.cache/screen_timeout_state"

# Initialize state file if it doesn't exist (default: on)
if [ ! -f "$STATE_FILE" ]; then
    echo "on" > "$STATE_FILE"
fi

# Read current state
CURRENT_STATE=$(cat "$STATE_FILE")

# Toggle the state
if [ "$CURRENT_STATE" = "on" ]; then
    # Turn off screen timeout
    systemctl --user stop hypridle.service 2>/dev/null
    pkill -f hypridle 2>/dev/null
    echo "off" > "$STATE_FILE"
    notify-send -t 2000 -u normal "Screen Timeout" "Screen timeout disabled" -i preferences-system-time
else
    # Turn on screen timeout
    systemctl --user start hypridle.service 2>/dev/null || hypridle &
    echo "on" > "$STATE_FILE"
    notify-send -t 2000 -u normal "Screen Timeout" "Screen timeout enabled" -i preferences-system-time
fi
