#!/bin/bash

# Script to hide specific system tray applications
# Add application names you want to hide from the system tray

# List of applications to hide (you can add more)
HIDDEN_APPS=(
    "equibop"
    "discord"
    "steam"
    # Add more apps here as needed
)

# Function to check if app should be hidden
hide_app() {
    local app_name="$1"
    for hidden in "${HIDDEN_APPS[@]}"; do
        if [[ "$app_name" == *"$hidden"* ]]; then
            return 0  # Hide this app
        fi
    done
    return 1  # Don't hide this app
}

# You can call this script from other applications or use it as reference
# This is mainly for documentation of which apps you want to hide

echo "Apps configured to be hidden from system tray:"
printf '%s\n' "${HIDDEN_APPS[@]}"
