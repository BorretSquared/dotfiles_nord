#!/bin/bash

# Kill any existing waybar instances
killall waybar 2>/dev/null

# Wait a moment for processes to terminate
sleep 1

# Launch waybar with Wayland backend
GDK_BACKEND=wayland waybar &

echo "Waybar launched with Nord light theme"
