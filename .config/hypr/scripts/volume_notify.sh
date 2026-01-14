#!/bin/bash
# Volume notification script with progress bar and device name

# Get the device name from wpctl status (the line with * is the active sink)
device_name=$(wpctl status | grep -A 20 "Sinks:" | grep "\*" | head -1 | sed 's/.*\. //' | sed 's/\[vol:.*//' | xargs)

# If device name is empty, use a fallback
if [ -z "$device_name" ]; then
    device_name="Audio Output"
fi

# Get current volume and mute status
volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c "MUTED")

if [ "$is_muted" -eq 1 ]; then
    notify-send -a "volume" -u low -h string:x-canonical-private-synchronous:volume \
        -h int:value:0 "Volume: $device_name" "Muted"
else
    notify-send -a "volume" -u low -h string:x-canonical-private-synchronous:volume \
        -h int:value:"$volume" "Volume: $device_name" "$volume%"
fi
