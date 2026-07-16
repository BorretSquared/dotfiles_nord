#!/bin/bash
# Custom AirPods stem double-tap handler (not part of LibrePods).
# AirPods only emit XF86AudioPlay/Pause; this turns a second tap into next track.
#
# Original path on both installs: ~/.config/hypr/scripts/airpods_double_tap.sh
# Bind XF86AudioPlay and XF86AudioPause to this script.

LOG_FILE="/tmp/airpods_debug.log"
TIME_FILE="/tmp/airpods_tap_time"
CURRENT_TIME=$(date +%s%3N)

echo "[$CURRENT_TIME] Script triggered" >> "$LOG_FILE"

if [ -f "$TIME_FILE" ]; then
    LAST_TIME=$(cat "$TIME_FILE")
    DIFF=$((CURRENT_TIME - LAST_TIME))
    echo "[$CURRENT_TIME] DIFF: $DIFF" >> "$LOG_FILE"

    if [ "$DIFF" -lt 1000 ]; then
        echo "[$CURRENT_TIME] Double tap detected! Skipping." >> "$LOG_FILE"
        rm -f "$TIME_FILE"
        # Revert the accidental play/pause from the first tap
        playerctl play-pause
        playerctl next
        exit 0
    fi
fi

echo "[$CURRENT_TIME] First tap. Writing time to $TIME_FILE" >> "$LOG_FILE"
echo "$CURRENT_TIME" > "$TIME_FILE"
playerctl play-pause
