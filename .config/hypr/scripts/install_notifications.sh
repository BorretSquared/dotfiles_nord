#!/bin/bash
# Install notification daemon and dependencies

echo "Installing mako notification daemon..."

# Detect package manager
if command -v pacman &> /dev/null; then
    # Arch-based
    sudo pacman -S --needed mako libnotify
elif command -v apt &> /dev/null; then
    # Debian-based
    sudo apt install mako-notifier libnotify-bin
elif command -v dnf &> /dev/null; then
    # Fedora-based
    sudo dnf install mako libnotify
else
    echo "Unsupported package manager. Please install 'mako' and 'libnotify' manually."
    exit 1
fi

echo ""
echo "✓ Installation complete!"
echo ""
echo "To activate the notification daemon:"
echo "1. Reload Hyprland config: hyprctl reload"
echo "   OR restart Hyprland"
echo ""
echo "2. Test notifications with: ~/.config/hypr/scripts/test_notifications.sh"
echo ""
echo "The notifications will have smooth slide-in animations matching your Hyprland setup!"
