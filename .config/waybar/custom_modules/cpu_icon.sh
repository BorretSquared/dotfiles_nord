#!/bin/bash

# Calculate CPU usage over a very short window (0.2s) to keep it snappy
read -r cpu a b c previdle rest < /proc/stat
prevtotal=$((a+b+c+previdle))
sleep 0.2
read -r cpu a b c idle rest < /proc/stat
total=$((a+b+c+idle))

cpu_usage=$((100 * ( (total-prevtotal) - (idle-previdle) ) / (total-prevtotal) ))

# Round to nearest 5
rounded=$(( (cpu_usage + 2) / 5 * 5 ))
[ "$rounded" -gt 100 ] && rounded=100
[ "$rounded" -lt 0 ] && rounded=0

echo "/home/borret/.config/waybar/cpu_speed_icons/speed_${rounded}.svg"