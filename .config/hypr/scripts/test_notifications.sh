#!/bin/bash
# Test notification system

echo "Testing notification system..."
echo ""

# Test basic notification
echo "1. Testing basic notification..."
notify-send "Test Notification" "If you see this, notifications are working!"
sleep 2

# Test with different urgencies
echo "2. Testing low urgency (3 second timeout)..."
notify-send -u low "Low Priority" "This is a low priority notification"
sleep 3

echo "3. Testing normal urgency (5 second timeout)..."
notify-send -u normal "Normal Priority" "This is a normal priority notification"
sleep 3

echo "4. Testing critical urgency (stays until dismissed)..."
notify-send -u critical "Critical Alert" "This is a critical notification - dismiss it manually!"
sleep 2

# Test volume notification
echo "5. Testing volume notification style..."
notify-send -a "volume" -h int:value:75 "Volume Test" "🔊 75%"
sleep 3

# Test brightness notification
echo "6. Testing brightness notification style..."
notify-send -a "brightness" -h int:value:60 "Brightness Test" "☀️ 60%"
sleep 3

# Test battery notification
echo "7. Testing battery notification style..."
notify-send -a "battery" "Battery Test" "🔋 50% remaining"
sleep 3

# Test with icon
echo "8. Testing notification with icon..."
notify-send -i dialog-information "Icon Test" "This notification has an icon"
sleep 2

echo ""
echo "✓ Test complete!"
echo ""
echo "Controls:"
echo "  - Notifications appear in top-right with slide animation"
echo "  - Click to dismiss"
echo "  - Critical notifications require manual dismissal"
echo "  - Multiple notifications stack vertically"
echo ""
echo "To check mako status: makoctl mode"
echo "To dismiss all: makoctl dismiss --all"
echo "To reload config: makoctl reload"
