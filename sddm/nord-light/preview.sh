#!/bin/bash

# Nord Light SDDM Theme Preview Script
# Run this script to preview the theme using sddm-greeter

THEME_NAME="nord-light"
THEME_PATH="$HOME/sddm-themes/$THEME_NAME"

echo "🎨 Previewing Nord Light SDDM Theme..."

# Check if theme exists
if [ ! -d "$THEME_PATH" ]; then
    echo "❌ Error: Theme not found at $THEME_PATH"
    exit 1
fi

# Check if sddm-greeter is available
if ! command -v sddm-greeter &> /dev/null; then
    echo "⚠️  sddm-greeter not found. Installing SDDM development tools..."
    
    # Detect package manager and install
    if command -v pacman &> /dev/null; then
        echo "📦 Installing with pacman..."
        sudo pacman -S --needed sddm
    elif command -v apt &> /dev/null; then
        echo "📦 Installing with apt..."
        sudo apt update && sudo apt install sddm
    elif command -v dnf &> /dev/null; then
        echo "📦 Installing with dnf..."
        sudo dnf install sddm
    else
        echo "❌ Could not detect package manager. Please install SDDM manually."
        exit 1
    fi
fi

echo "🔍 Launching theme preview..."
echo "Press Ctrl+C to exit preview"

# Create temporary config for preview
TEMP_CONF=$(mktemp)
cat > "$TEMP_CONF" << EOF
[Theme]
Current=$THEME_NAME
ThemeDir=$HOME/sddm-themes

[General]
DisplayServer=x11

[X11]
ServerPath=/usr/bin/X
SessionDir=/usr/share/xsessions
EOF

# Launch preview
sddm-greeter --test-mode --theme "$THEME_PATH" &
GREETER_PID=$!

echo "👁️  Preview launched (PID: $GREETER_PID)"
echo "🛑 Press Enter to stop preview..."
read

# Clean up
kill $GREETER_PID 2>/dev/null || true
rm -f "$TEMP_CONF"

echo "✅ Preview ended"
