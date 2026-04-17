#!/bin/bash

# Nord Light SDDM Theme Installation Script
# Run this script to install the Nord Light SDDM theme

set -e

THEME_NAME="nord-light"
THEME_SOURCE="$(pwd)"
THEME_DEST="/usr/share/sddm/themes/$THEME_NAME"
SDDM_CONF="/etc/sddm.conf"

echo "🎨 Installing Nord Light SDDM Theme..."

# Check if source theme exists (look for Main.qml to verify it's a theme directory)
if [ ! -f "$THEME_SOURCE/Main.qml" ]; then
    echo "❌ Error: Theme source directory not found or invalid at $THEME_SOURCE"
    echo "Please make sure you're running this script from the theme directory."
    echo "Expected to find Main.qml in the current directory."
    exit 1
fi

# Check if running as root for system installation
if [ "$EUID" -ne 0 ]; then
    echo "🔐 This script needs to be run with sudo to install system-wide."
    echo "Usage: sudo ./install.sh"
    exit 1
fi

# Create backup of existing SDDM config if it exists
if [ -f "$SDDM_CONF" ]; then
    echo "📋 Backing up existing SDDM configuration..."
    cp "$SDDM_CONF" "$SDDM_CONF.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Copy theme files
echo "📁 Copying theme files to $THEME_DEST..."
mkdir -p "$THEME_DEST"
cp -r "$THEME_SOURCE"/* "$THEME_DEST/"

# Set proper permissions
echo "🔒 Setting proper permissions..."
chown -R root:root "$THEME_DEST"
chmod -R 755 "$THEME_DEST"

# Configure SDDM to use the new theme
echo "⚙️  Configuring SDDM..."

# Create sddm.conf if it doesn't exist
if [ ! -f "$SDDM_CONF" ]; then
    cat > "$SDDM_CONF" << EOF
[Theme]
Current=$THEME_NAME

[Autologin]
Relogin=false
Session=
User=

[General]
HaltCommand=
RebootCommand=

[Users]
MaximumUid=60000
MinimumUid=1000
EOF
else
    # Update existing config
    if grep -q "^\[Theme\]" "$SDDM_CONF"; then
        # Theme section exists, update Current line
        if grep -q "^Current=" "$SDDM_CONF"; then
            sed -i "s/^Current=.*/Current=$THEME_NAME/" "$SDDM_CONF"
        else
            sed -i "/^\[Theme\]/a Current=$THEME_NAME" "$SDDM_CONF"
        fi
    else
        # No Theme section, add it
        echo "" >> "$SDDM_CONF"
        echo "[Theme]" >> "$SDDM_CONF"
        echo "Current=$THEME_NAME" >> "$SDDM_CONF"
    fi
fi

echo "✅ Nord Light SDDM theme installed successfully!"
echo ""
echo "📋 Installation Summary:"
echo "   Theme installed to: $THEME_DEST"
echo "   SDDM config: $SDDM_CONF"
echo "   Theme activated: $THEME_NAME"
echo ""
echo "🔄 To apply the theme, restart SDDM:"
echo "   sudo systemctl restart sddm"
echo ""
echo "⚠️  Warning: This will log you out of your current session!"
echo ""
echo "💡 Optional: You can customize the theme by editing:"
echo "   $THEME_DEST/theme.conf"
echo ""

read -p "Would you like to restart SDDM now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 Restarting SDDM..."
    systemctl restart sddm
else
    echo "👍 Remember to restart SDDM when you're ready to see the new theme!"
fi
