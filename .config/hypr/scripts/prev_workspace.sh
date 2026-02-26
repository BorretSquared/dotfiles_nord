#!/bin/bash
# Cycle to the previous workspace (1-10), wrapping 1 -> 10
current=$(hyprctl activeworkspace -j | jq '.id')
prev=$(( (current - 2 + 10) % 10 + 1 ))
hyprctl dispatch workspace "$prev"
