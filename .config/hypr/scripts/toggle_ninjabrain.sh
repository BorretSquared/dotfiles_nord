#!/bin/bash
# Toggle Ninjabrain Bot Overlay
LOG="/tmp/ninjabrain_toggle.log"
echo "--- Running Toggle $(date) ---" >> "$LOG"

# Get window info using jq for reliability
# We select the FIRST matching window if multiple exist
WINDOW_JSON=$(hyprctl clients -j | jq -c '.[] | select(.class == "ninjabrainbot-Main") | {address, pinned, floating}')

echo "Window JSON: $WINDOW_JSON" >> "$LOG"

if [ -z "$WINDOW_JSON" ]; then
    notify-send "Ninja Brain Bot" "Window not found"
    echo "Window not found" >> "$LOG"
    exit 1
fi

ADDR=$(echo "$WINDOW_JSON" | jq -r '.address')
PINNED=$(echo "$WINDOW_JSON" | jq -r '.pinned')
FLOATING=$(echo "$WINDOW_JSON" | jq -r '.floating')

echo "ADDR: $ADDR, PINNED: '$PINNED', FLOATING: '$FLOATING'" >> "$LOG"

if [ "$PINNED" == "true" ]; then
    echo "Action: Unpinning" >> "$LOG"
    # Currently pinned. Turn OFF.
    hyprctl dispatch pin address:$ADDR
    hyprctl dispatch setfloating address:$ADDR 0
    notify-send "Ninja Brain Bot" "Interactive Mode"
else
    echo "Action: Pinning" >> "$LOG"
    # Currently unpinned. Turn ON.
    
    # Ensure floating
    if [ "$FLOATING" == "false" ]; then
        echo "Action: Floating first" >> "$LOG"
        hyprctl dispatch setfloating address:$ADDR
    fi
    
    hyprctl dispatch pin address:$ADDR
    notify-send "Ninja Brain Bot" "Overlay Mode"
fi
