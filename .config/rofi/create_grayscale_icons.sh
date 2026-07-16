#!/bin/bash

# Create grayscale icon theme for rofi
# This converts Papirus icons to grayscale

ICON_THEME="Papirus"
OUTPUT_DIR="$HOME/.local/share/icons/Papirus-Gray"
SOURCE_DIR="/usr/share/icons/$ICON_THEME"

echo "Creating grayscale icon theme from $ICON_THEME..."

# Create output directory structure
mkdir -p "$OUTPUT_DIR"

# Copy the index.theme file
if [ -f "$SOURCE_DIR/index.theme" ]; then
    cp "$SOURCE_DIR/index.theme" "$OUTPUT_DIR/"
    # Update the theme name
    sed -i 's/Name=.*/Name=Papirus-Gray/' "$OUTPUT_DIR/index.theme"
fi

# Only convert the most commonly used sizes for performance
SIZES=("48x48" "32x32" "24x24" "16x16")

for size in "${SIZES[@]}"; do
    if [ -d "$SOURCE_DIR/$size/apps" ]; then
        echo "Processing $size/apps..."
        mkdir -p "$OUTPUT_DIR/$size/apps"
        
        # Convert only app icons to grayscale
        find "$SOURCE_DIR/$size/apps" -name "*.svg" | while read -r icon; do
            basename_icon=$(basename "$icon")
            output_icon="$OUTPUT_DIR/$size/apps/$basename_icon"
            
            # Convert to grayscale using ImageMagick
            if [ ! -f "$output_icon" ]; then
                convert "$icon" -colorspace Gray "$output_icon" 2>/dev/null
            fi
        done
    fi
done

echo "Grayscale icon theme created at $OUTPUT_DIR"
echo "You can now use 'Papirus-Gray' as your icon theme in rofi"
