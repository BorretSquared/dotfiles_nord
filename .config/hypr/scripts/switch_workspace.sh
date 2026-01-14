#!/bin/bash
# Script to switch workspaces and close hyprexpo if open
# Usage: switch_workspace.sh <workspace_number>

TARGET_WORKSPACE=$1

# Get current workspace
CURRENT_WORKSPACE=$(hyprctl activeworkspace -j | jq -r '.id')

# Close hyprexpo and switch workspace
# The key is to only do this if we're actually changing workspaces
if [ "$CURRENT_WORKSPACE" != "$TARGET_WORKSPACE" ]; then
    hyprctl dispatch workspace "$TARGET_WORKSPACE"
else
    # If we're on the same workspace, just close expo
    hyprctl dispatch hyprexpo:expo off
fi
