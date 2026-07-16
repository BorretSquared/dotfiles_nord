#!/bin/bash

# Streamlined lock services startup
LOG_FILE="/home/borret/hibernation.log"

log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

log_msg "Starting lock services..."

# Reload systemd user daemon
systemctl --user daemon-reload

# Enable services (ignore if already enabled)
systemctl --user enable hypridle.service 2>/dev/null || true

# Stop any existing instances to avoid conflicts
systemctl --user stop hypridle.service 2>/dev/null || true
pkill -f hypridle 2>/dev/null || true

# Start hypridle service
if systemctl --user start hypridle.service; then
    log_msg "Hypridle service started successfully"
else
    log_msg "Failed to start hypridle service"
    exit 1
fi

# Verify it's running
sleep 1
if systemctl --user is-active hypridle.service >/dev/null 2>&1; then
    log_msg "Lock services ready"
else
    log_msg "Warning: Hypridle service not active after startup"
fi
