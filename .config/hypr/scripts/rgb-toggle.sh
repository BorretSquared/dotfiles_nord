#!/bin/bash

STATE_FILE="/tmp/rgb_state"
PROFILE_DIR="$HOME/.config/OpenRGB"

# Read the current state, default to 'on' if the file doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "on" > "$STATE_FILE"
fi

STATE=$(cat "$STATE_FILE")

if [ "$STATE" == "on" ]; then
    # The lights are currently on, so turn them off
    ~/.config/hypr/scripts/gpu-rgb-off.sh
    echo "off" > "$STATE_FILE"
    notify-send -a "OpenRGB" -t 2000 "GPU RGB" "Toggled OFF 🌙"
else
    # The lights are currently off, so turn them on
    openrgb -p "$PROFILE_DIR/gpu-on.orp"
    echo "on" > "$STATE_FILE"
    notify-send -a "OpenRGB" -t 2000 "GPU RGB" "Toggled ON 💡"
fi