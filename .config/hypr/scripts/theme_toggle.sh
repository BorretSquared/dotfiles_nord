#!/bin/bash

# Configuration paths
declare -A PATHS=(
    [HYPRPAPER]="$HOME/.config/hypr/hyprpaper.conf"
    [VSCODE]="$HOME/.config/Code/User/settings.json"
    [EQUIBOP]="$HOME/.config/equibop/settings.json"
    [ZSHRC]="$HOME/.zshrc"
    [WAYBAR]="$HOME/.config/waybar/style.css"
    [KITTY]="$HOME/.config/kitty/kitty.conf"
    [ROFI]="$HOME/.config/rofi/config.rasi"
    [PRISM]="$HOME/.local/share/PrismLauncher/prismlauncher.cfg"
    [HYPRLAND]="$HOME/.config/hypr/hyprland.conf"
    [DUNST]="$HOME/.config/dunst/dunstrc"
    [DUNST_LIGHT]="$HOME/.config/dunst/dunstrc.light"
    [DUNST_DARK]="$HOME/.config/dunst/dunstrc.dark"
)

# Theme definitions: [light_value]=[dark_value]
declare -A REPLACEMENTS=(
    # Wallpapers
    ["GreatWallStairs.jpg"]="misty_mountains.jpg"
    # VS Code
    ['"Nord Light"']='"Nord"'
    # Equibop
    ['"DARK_MODE": false']='"DARK_MODE": true'
    # Waybar colors
    ["@define-color window_bg #c9d6e5;"]="@define-color window_bg #3B4252;"
    ["@define-color center_bg #c9d5e5;"]="@define-color center_bg #3B4252;"
    ["@define-color light #dde1e8;"]="@define-color light #4C566A;"
    ["@define-color text_dark #2E3440;"]="@define-color text_dark #ECEFF4;"
    # Kitty colors
    ["foreground #2E3440"]="foreground #D8DEE9"
    ["background #E5E9F0"]="background #2E3440"
    ["selection_foreground #2E3440"]="selection_foreground #D8DEE9"
    ["selection_background #D8DEE9"]="selection_background #4C566A"
    # Rofi
    ["nord-light.rasi"]="nord-dark.rasi"
    # Prism Launcher
    ["ApplicationTheme=light"]="ApplicationTheme=dark"
    # Hyprland
    ["env = GTK_THEME,Adwaita:light"]="env = GTK_THEME,Adwaita:dark"
    ["env = QT_STYLE_OVERRIDE,Adwaita-Light"]="env = QT_STYLE_OVERRIDE,Adwaita-Dark"
    ["env = COLOR_SCHEME,prefer-light"]="env = COLOR_SCHEME,prefer-dark"
    ["col.active_border = rgba(5e81acff)"]="col.active_border = rgba(88c0d0ff)"
    ["col.inactive_border = rgba(d8dee9ff)"]="col.inactive_border = rgba(4c566aff)"
)

# Detect current theme
is_light_theme() {
    grep -q "GreatWallStairs.jpg" "${PATHS[HYPRPAPER]}"
}

# Perform replacements
toggle_theme() {
    local light_to_dark=$1
    
    for light in "${!REPLACEMENTS[@]}"; do
        dark="${REPLACEMENTS[$light]}"
        
        if [ "$light_to_dark" = true ]; then
            # Light → Dark
            sed -i "s|$light|$dark|g" "${PATHS[HYPRPAPER]}" "${PATHS[VSCODE]}" "${PATHS[EQUIBOP]}" \
                "${PATHS[WAYBAR]}" "${PATHS[KITTY]}" "${PATHS[ROFI]}" "${PATHS[PRISM]}" "${PATHS[HYPRLAND]}" 2>/dev/null
        else
            # Dark → Light
            sed -i "s|$dark|$light|g" "${PATHS[HYPRPAPER]}" "${PATHS[VSCODE]}" "${PATHS[EQUIBOP]}" \
                "${PATHS[WAYBAR]}" "${PATHS[KITTY]}" "${PATHS[ROFI]}" "${PATHS[PRISM]}" "${PATHS[HYPRLAND]}" 2>/dev/null
        fi
    done
}

# Restart services
restart_services() {
    local theme=$1
    
    # Hyprpaper
    killall hyprpaper 2>/dev/null
    hyprpaper &
    
    # Waybar
    killall waybar 2>/dev/null
    waybar &
    
    # Kitty (reload config)
    killall -SIGUSR1 kitty 2>/dev/null
    
    # Dunst
    if [ "$theme" = "dark" ]; then
        cp "${PATHS[DUNST_DARK]}" "${PATHS[DUNST]}"
        /bin/zsh -lc "source '${PATHS[ZSHRC]}' && ash-theme"
    else
        cp "${PATHS[DUNST_LIGHT]}" "${PATHS[DUNST]}"
        /bin/zsh -lc "source '${PATHS[ZSHRC]}' && light-theme"
    fi
    killall mako dunst 2>/dev/null
    dunst &
}

# Main logic
if is_light_theme; then
    echo "Switching to Dark Theme..."
    toggle_theme true
    restart_services "dark"
else
    echo "Switching to Light Theme..."
    toggle_theme false
    restart_services "light"
fi

echo "Theme toggled successfully!"
