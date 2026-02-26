#!/bin/bash

# Waybar Weather Script
# Change the location below to match your city
LOCATION="Carmel,NY"

# Fetch temperature and weather condition
WEATHER_DATA=$(curl -s --max-time 10 "wttr.in/${LOCATION}?format=%t,%C&m" 2>/dev/null)

if [ -z "$WEATHER_DATA" ] || [ "$WEATHER_DATA" = "" ]; then
    echo "N/A"
    exit 1
fi

# Split temperature and condition
TEMP=$(echo "$WEATHER_DATA" | cut -d',' -f1 | sed 's/[^0-9-]//g')
CONDITION=$(echo "$WEATHER_DATA" | cut -d',' -f2 | xargs)

# Convert Fahrenheit to Celsius if needed
if [ "$TEMP" -gt 50 ]; then
    TEMP=$(echo "scale=0; ($TEMP - 32) * 5 / 9" | bc 2>/dev/null || echo "$TEMP")
fi

# Map weather conditions to Nerd Font icons (two-tone style)
get_weather_icon() {
    case "$1" in
        *"Clear"*|*"Sunny"*)
            echo "󰖙"  # Clear day
            ;;
        *"Partly cloudy"*|*"Partly Cloudy"*)
            echo "󰖕"  # Partly cloudy day
            ;;
        *"Cloudy"*|*"Overcast"*)
            echo "󰖐"  # Cloudy
            ;;
        *"Rain"*|*"Drizzle"*|*"Shower"*)
            echo "󰖗"  # Rain
            ;;
        *"Snow"*|*"Sleet"*)
            echo "󰖘"  # Snow
            ;;
        *"Thunder"*|*"Storm"*)
            echo "󰖓"  # Thunderstorm
            ;;
        *"Fog"*|*"Mist"*)
            echo "󰖑"  # Fog
            ;;
        *"Wind"*)
            echo "󰖝"  # Windy
            ;;
        *)
            echo "󰖕"  # Default partly cloudy
            ;;
    esac
}

ICON=$(get_weather_icon "$CONDITION")
echo "$ICON $TEMP"
