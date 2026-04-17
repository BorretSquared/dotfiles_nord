#!/bin/bash

# Nord Light SDDM Theme Uninstallation Script
# Run this script to remove the Nord Light SDDM theme

set -e

THEME_NAME="nord-light"
THEME_DEST="/usr/share/sddm/themes/$THEME_NAME"
SDDM_CONF="/etc/sddm.conf"

echo "🗑️  Uninstalling Nord Light SDDM Theme..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "🔐 This script needs to be run with sudo to uninstall system-wide."
    echo "Usage: sudo ./uninstall.sh"
    exit 1
fi

# Remove theme directory
if [ -d "$THEME_DEST" ]; then
    echo "📁 Removing theme files from $THEME_DEST..."
    rm -rf "$THEME_DEST"
else
    echo "⚠️  Theme directory not found at $THEME_DEST"
fi

# Reset SDDM theme to default
if [ -f "$SDDM_CONF" ]; then
    echo "⚙️  Resetting SDDM configuration..."
    if grep -q "^Current=$THEME_NAME" "$SDDM_CONF"; then
        sed -i "s/^Current=$THEME_NAME.*/Current=/" "$SDDM_CONF"
        echo "✅ SDDM theme reset to default"
    else
        echo "ℹ️  SDDM was not configured to use Nord Light theme"
    fi
else
    echo "⚠️  SDDM configuration file not found"
fi

echo "✅ Nord Light SDDM theme uninstalled successfully!"
echo ""
echo "🔄 To apply changes, restart SDDM:"
echo "   sudo systemctl restart sddm"
