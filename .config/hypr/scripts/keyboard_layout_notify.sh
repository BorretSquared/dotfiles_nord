#!/usr/bin/env bash

# Switch to next keyboard layout
hyprctl switchxkblayout all next

# Get the current layout for all keyboards
# We'll get the first keyboard's layout (most systems have one)
layout_info=$(hyprctl devices -j | jq -r '.keyboards[0].active_keymap')

# Make the layout name more readable
case "$layout_info" in
    *"English (ATP v3)"*)
        layout_name="APTv3 (English)"
        ;;
    *"APT v3 + German AltGr"*)
        layout_name="APTv3 (German)"
        ;;
    *"English (US)"*)
        layout_name="QWERTY (English)"
        ;;
    *)
        layout_name="$layout_info"
        ;;
esac

# Send notification
notify-send -u low -t 2000 "Keyboard Layout" "Switched to: $layout_name"
