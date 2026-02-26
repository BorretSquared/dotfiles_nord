#!/bin/bash
# Cycle to the next workspace (1-10), wrapping 10 -> 1
current=$(hyprctl activeworkspace -j | jq '.id')
next=$(( current % 10 + 1 ))
hyprctl dispatch workspace "$next"
