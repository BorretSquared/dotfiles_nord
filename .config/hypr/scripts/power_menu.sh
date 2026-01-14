#!/bin/bash

# Power menu script for Hyprland

# Options
options="Shutdown\nHibernate\nLock\nReboot"

# Show menu and get selection
chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power Menu" -theme-str 'window {width: 300px;}')

# Execute based on selection
case $chosen in
    Lock)
        hyprlock --grace 0 &
        ;;
    Hibernate)
        systemctl hibernate &
        ;;
    Reboot)
        systemctl reboot &
        ;;
    Shutdown)
        systemctl poweroff &
        ;;
esac

# Exit the script immediately after launching the command
exit 0
