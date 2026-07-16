#!/bin/bash
# Toggle Nord light/dark across hyprpaper, waybar, kitty, rofi, VS Code, etc.
# Light wallpaper: GreatWallStairs.png
# Dark wallpaper:  misty_mountains.jpg

set -u

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
    [HYPRLAND_LUA]="$HOME/.config/hypr/hyprland.lua"
    [DUNST]="$HOME/.config/dunst/dunstrc"
    [DUNST_LIGHT]="$HOME/.config/dunst/dunstrc.light"
    [DUNST_DARK]="$HOME/.config/dunst/dunstrc.dark"
)

# [light_value]=[dark_value]
declare -A REPLACEMENTS=(
    # Wallpapers (filename only — works with any path prefix)
    ["GreatWallStairs.png"]="misty_mountains.jpg"
    # VS Code
    ['"Nord Light"']='"Nord"'
    # Equibop / Vesktop-style dark mode flag
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
    # Hyprland classic conf
    ["env = GTK_THEME,Adwaita:light"]="env = GTK_THEME,Adwaita:dark"
    ["env = QT_STYLE_OVERRIDE,Adwaita-Light"]="env = QT_STYLE_OVERRIDE,Adwaita-Dark"
    ["env = COLOR_SCHEME,prefer-light"]="env = COLOR_SCHEME,prefer-dark"
    ["col.active_border = rgba(5e81acff)"]="col.active_border = rgba(88c0d0ff)"
    ["col.inactive_border = rgba(d8dee9ff)"]="col.inactive_border = rgba(4c566aff)"
    # Hyprland lua (desktop)
    ['hl.env("GTK_THEME", "Adwaita:light")']='hl.env("GTK_THEME", "Adwaita:dark")'
    ['hl.env("QT_STYLE_OVERRIDE", "Adwaita-Light")']='hl.env("QT_STYLE_OVERRIDE", "Adwaita-Dark")'
    ['hl.env("COLOR_SCHEME", "prefer-light")']='hl.env("COLOR_SCHEME", "prefer-dark")'
    ['["col.active_border"] = "rgba(5e81acff)"']='["col.active_border"] = "rgba(88c0d0ff)"'
    ['["col.inactive_border"] = "rgba(d8dee9ff)"']='["col.inactive_border"] = "rgba(4c566aff)"'
)

is_light_theme() {
    # Prefer explicit light wallpaper; also treat legacy .jpg path as light
    grep -qE 'GreatWallStairs\.(png|jpg)' "${PATHS[HYPRPAPER]}" 2>/dev/null
}

toggle_theme() {
    local light_to_dark=$1
    local targets=(
        "${PATHS[HYPRPAPER]}"
        "${PATHS[VSCODE]}"
        "${PATHS[EQUIBOP]}"
        "${PATHS[WAYBAR]}"
        "${PATHS[KITTY]}"
        "${PATHS[ROFI]}"
        "${PATHS[PRISM]}"
        "${PATHS[HYPRLAND]}"
        "${PATHS[HYPRLAND_LUA]}"
    )

    for light in "${!REPLACEMENTS[@]}"; do
        dark="${REPLACEMENTS[$light]}"
        if [ "$light_to_dark" = true ]; then
            sed -i "s|$light|$dark|g" "${targets[@]}" 2>/dev/null || true
        else
            sed -i "s|$dark|$light|g" "${targets[@]}" 2>/dev/null || true
        fi
    done
}

restart_services() {
    local theme=$1

    killall hyprpaper 2>/dev/null || true
    hyprpaper &

    killall waybar 2>/dev/null || true
    waybar &

    killall -SIGUSR1 kitty 2>/dev/null || true

    # Notifications: prefer dunst when themed configs exist, else mako
    if [ "$theme" = "dark" ]; then
        [ -f "${PATHS[DUNST_DARK]}" ] && cp "${PATHS[DUNST_DARK]}" "${PATHS[DUNST]}" 2>/dev/null || true
        /bin/zsh -lc "source '${PATHS[ZSHRC]}' && ash-theme" 2>/dev/null || true
    else
        [ -f "${PATHS[DUNST_LIGHT]}" ] && cp "${PATHS[DUNST_LIGHT]}" "${PATHS[DUNST]}" 2>/dev/null || true
        /bin/zsh -lc "source '${PATHS[ZSHRC]}' && light-theme" 2>/dev/null || true
    fi

    killall mako dunst 2>/dev/null || true
    if [ -f "${PATHS[DUNST]}" ] && command -v dunst >/dev/null 2>&1; then
        dunst &
    else
        mako &
    fi
}

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
