#!/bin/bash
# Battery notification script

# Get battery info
battery_path="/sys/class/power_supply/BAT0"
if [ ! -d "$battery_path" ]; then
    battery_path="/sys/class/power_supply/BAT1"
fi

if [ -d "$battery_path" ]; then
    capacity=$(cat "$battery_path/capacity")
    status=$(cat "$battery_path/status")
    
    # Low battery warning
    if [ "$capacity" -le 10 ] && [ "$status" = "Discharging" ]; then
        notify-send -a "battery" -u critical "Battery Critical" "$capacity% - Plug in charger!"
    elif [ "$capacity" -le 20 ] && [ "$status" = "Discharging" ]; then
        notify-send -a "battery" -u normal "Battery Low" "$capacity% remaining"
    fi
fi
