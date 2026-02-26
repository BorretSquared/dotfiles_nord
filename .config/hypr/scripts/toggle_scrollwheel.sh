#!/bin/bash

# Define device name
DEVICE="logitech-g305-1"

# Get current scroll factor using hyprctl and jq
CURRENT_FACTOR=$(hyprctl -j devices | jq -r ".mice[] | select(.name == \"$DEVICE\") | .scrollFactor")

# Check if current factor is effectively 0
IS_ZERO=$(echo "$CURRENT_FACTOR" | awk '{if ($1 == 0) print 1; else print 0}')

if [ "$IS_ZERO" -eq 1 ]; then
    # Enable scrolling
    # Restore from file or default to -1.0 (natural scrolling seems to be the user's preference)
    if [ -f /tmp/hypr_scroll_restore ]; then
        NEW_FACTOR=$(cat /tmp/hypr_scroll_restore)
    else
        NEW_FACTOR="-1.0"
    fi
    
    hyprctl keyword device:$DEVICE:scroll_factor $NEW_FACTOR
    notify-send -h string:x-canonical-private-synchronous:scroll_toggle "Scroll Wheel" "Enabled ($NEW_FACTOR)"
else
    # Disable scrolling
    echo "$CURRENT_FACTOR" > /tmp/hypr_scroll_restore
    hyprctl keyword device:$DEVICE:scroll_factor 0
    notify-send -h string:x-canonical-private-synchronous:scroll_toggle "Scroll Wheel" "Disabled"
fi
