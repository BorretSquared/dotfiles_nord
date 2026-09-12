#!/bin/bash
# AirPods Pro 2 Auto-Profile Script
# Automatically connects AirPods via Bluetooth and switches to A2DP profile

AIRPODS_MAC="6C:12:70:30:6C:B8"
CARD_NAME="bluez_card.6C_12_70_30_6C_B8"

# 1. Check if AirPods are connected via Bluetooth. If not, connect them.
if ! bluetoothctl info "$AIRPODS_MAC" | grep -q "Connected: yes"; then
    echo "AirPods not connected. Connecting via Bluetooth..."
    bluetoothctl connect "$AIRPODS_MAC"
    
    # Wait for the audio card to appear
    echo "Waiting for audio card to be detected..."
    for i in {1..10}; do
        if pactl list cards short | grep -q "$CARD_NAME"; then
            break
        fi
        sleep 1
    done
fi

# 2. Check if card exists and switch to A2DP profile
# Honor bt-audio-mode (Super+V): quality=AAC, range=SBC
if pactl list cards short | grep -q "$CARD_NAME"; then
    MODE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/bt-audio-mode"
    MODE="quality"
    [[ -f "$MODE_FILE" ]] && MODE="$(cat "$MODE_FILE")"
    if [[ "$MODE" == "range" ]]; then
        PROFILE="a2dp-sink-sbc"
        echo "AirPods detected, switching to range profile (SBC)..."
    else
        PROFILE="a2dp-sink"
        echo "AirPods detected, switching to quality profile (AAC)..."
    fi
    pactl set-card-profile "$CARD_NAME" "$PROFILE"
    
    # Wait for the sink to appear (PipeWire sink registration is asynchronous)
    echo "Waiting for audio sink..."
    for i in {1..10}; do
        SINK=$(pactl list sinks short | grep "bluez_output" | grep "6C_12_70_30_6C_B8" | awk '{print $2}')
        if [ -n "$SINK" ]; then
            break
        fi
        sleep 0.5
    done
    
    # Set as default sink
    if [ -n "$SINK" ]; then
        pactl set-default-sink "$SINK"
        echo "AirPods set as default sink: $SINK"
    else
        echo "Error: AirPods audio sink not found."
        exit 1
    fi
else
    echo "Error: AirPods audio card not detected by PipeWire."
    exit 1
fi
