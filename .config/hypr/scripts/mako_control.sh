#!/bin/bash
# Mako notification control script

case "$1" in
    "dismiss")
        makoctl dismiss
        ;;
    "dismiss-all")
        makoctl dismiss --all
        ;;
    "reload")
        makoctl reload
        echo "Mako config reloaded"
        ;;
    "mode")
        makoctl mode
        ;;
    "dnd")
        # Toggle Do Not Disturb mode
        if makoctl mode | grep -q "do-not-disturb"; then
            makoctl mode -r do-not-disturb
            notify-send "Do Not Disturb" "Notifications enabled"
        else
            makoctl mode -a do-not-disturb
            # This notification will still show before DND activates
            notify-send "Do Not Disturb" "Notifications silenced"
        fi
        ;;
    "history")
        makoctl history
        ;;
    *)
        echo "Mako Notification Control"
        echo ""
        echo "Usage: $0 {dismiss|dismiss-all|reload|mode|dnd|history}"
        echo ""
        echo "Commands:"
        echo "  dismiss      - Dismiss the most recent notification"
        echo "  dismiss-all  - Dismiss all notifications"
        echo "  reload       - Reload mako configuration"
        echo "  mode         - Show current mako mode"
        echo "  dnd          - Toggle Do Not Disturb mode"
        echo "  history      - Show notification history"
        exit 1
        ;;
esac
