#!/bin/bash

# This script runs when the lid is about to close
echo "$(date): Lid close detected, locking screen" >> /tmp/lid-handler.log

# Try to lock screen immediately
hyprlock &

# Give it a moment to appear
sleep 0.3

echo "$(date): Lock screen triggered" >> /tmp/lid-handler.log
