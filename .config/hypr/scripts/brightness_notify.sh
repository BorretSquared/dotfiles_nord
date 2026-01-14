#!/bin/bash
# Brightness notification script with progress bar

# Get current brightness percentage
brightness=$(brightnessctl get)
max_brightness=$(brightnessctl max)
brightness_percent=$((brightness * 100 / max_brightness))

notify-send -a "brightness" -u low -h string:x-canonical-private-synchronous:brightness \
    -h int:value:"$brightness_percent" "Brightness" "$brightness_percent%"
