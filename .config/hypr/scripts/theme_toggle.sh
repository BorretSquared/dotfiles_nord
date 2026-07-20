#!/usr/bin/env bash
# Toggle Nord light/dark across the Hyprland desktop.
# Bound to Super+Z. Default / preferred state: light (Nord).
#
# Covers: wallpaper, hyprland borders/env, waybar, kitty, rofi, mako,
# vesktop (+ equibop if present), VS Code, Prism Launcher, GTK/Qt
# color-scheme (drives Firefox "Nord Light & Dark" dual theme live via portal).
#
# State file: ~/.config/hypr/theme_state  (light|dark)
# Assets:     ~/.config/hypr/themes/

set -u

STATE_FILE="${HOME}/.config/hypr/theme_state"
LOCK_FILE="${XDG_RUNTIME_DIR:-/tmp}/theme_toggle.lock"
DEBOUNCE_SEC=1.2
THEMES_DIR="${HOME}/.config/hypr/themes"
LIGHT_WALL_FILE="${HOME}/.config/hypr/light_wallpaper.txt"
DARK_WALL_FILE="${HOME}/.config/hypr/dark_wallpaper.txt"
KDEGLOBALS="${HOME}/.config/kdeglobals"
COLOR_SCHEMES_DIR="${HOME}/.local/share/color-schemes"

HYPRPAPER_CONF="${HOME}/.config/hypr/hyprpaper.conf"
HYPRLAND_LUA="${HOME}/.config/hypr/hyprland.lua"
HYPRLAND_CONF="${HOME}/.config/hypr/hyprland.conf"
WAYBAR_STYLE="${HOME}/.config/waybar/style.css"
KITTY_CONF="${HOME}/.config/kitty/kitty.conf"
ROFI_CONF="${HOME}/.config/rofi/config.rasi"
MAKO_CONF="${HOME}/.config/mako/config"
VSCODE_SETTINGS="${HOME}/.config/Code/User/settings.json"
PRISM_CFG="${HOME}/.local/share/PrismLauncher/prismlauncher.cfg"
VESKTOP_CSS="${HOME}/.config/vesktop/settings/quickCss.css"
EQUIBOP_CSS="${HOME}/.config/equibop/settings/quickCss.css"
FF_PROFILE_DIR=""
FF_PREFS=""

# Resolve Firefox profile: prefer Install section Default=, else *.default-release
if [[ -f "${HOME}/.mozilla/firefox/profiles.ini" ]]; then
    FF_PATH=$(awk -F= '
        /^\[Install/ { in_i=1; next }
        /^\[/ { in_i=0 }
        in_i && $1=="Default" { print $2; exit }
    ' "${HOME}/.mozilla/firefox/profiles.ini")
    if [[ -z "${FF_PATH:-}" ]]; then
        FF_PATH=$(basename "$(find "${HOME}/.mozilla/firefox" -maxdepth 1 -type d -name '*.default-release' | head -n1)" 2>/dev/null || true)
    fi
    if [[ -n "${FF_PATH:-}" ]]; then
        if [[ "$FF_PATH" = /* ]]; then
            FF_PROFILE_DIR="$FF_PATH"
        else
            FF_PROFILE_DIR="${HOME}/.mozilla/firefox/${FF_PATH}"
        fi
        FF_PREFS="${FF_PROFILE_DIR}/user.js"
    fi
fi

DEFAULT_LIGHT_WALL="${HOME}/Documents/backgrounds/GreatWallStairs.jpg"
DEFAULT_DARK_WALL="${HOME}/Documents/backgrounds/Chudwig.png"

log() { printf '%s\n' "$*"; }

read_wall() {
    local file=$1 default=$2
    if [[ -f "$file" ]]; then
        local p
        p=$(head -n1 "$file" | tr -d '\r')
        if [[ -n "$p" && -f "$p" ]]; then
            printf '%s' "$p"
            return
        fi
    fi
    printf '%s' "$default"
}

current_theme() {
    if [[ -f "$STATE_FILE" ]]; then
        local s
        s=$(tr -d '[:space:]' <"$STATE_FILE")
        case "$s" in
            light|dark) printf '%s' "$s"; return ;;
        esac
    fi
    # Fallback: wallpaper filename
    if grep -qE 'GreatWallStairs\.(png|jpg)' "$HYPRPAPER_CONF" 2>/dev/null; then
        printf 'light'
    elif grep -qE 'Chudwig\.png|misty_mountains\.(png|jpg)|dark\.png' "$HYPRPAPER_CONF" 2>/dev/null; then
        printf 'dark'
    else
        printf 'light'
    fi
}

# --- helpers: in-place replace only if file exists ---
replace_in() {
    local file=$1
    local from=$2
    local to=$3
    [[ -f "$file" ]] || return 0
    # Use | as delimiter; escape sparingly — callers pass fixed strings
    if grep -qF -- "$from" "$file" 2>/dev/null; then
        sed -i "s|${from}|${to}|g" "$file"
    fi
}

set_json_string() {
    # set_json_string file key value  (top-level string only)
    local file=$1 key=$2 value=$3
    [[ -f "$file" ]] || return 0
    if command -v python3 >/dev/null 2>&1; then
        python3 - "$file" "$key" "$value" <<'PY'
import json, sys
path, key, value = sys.argv[1], sys.argv[2], sys.argv[3]
try:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    sys.exit(0)
data[key] = value
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=4)
    f.write("\n")
PY
    fi
}

set_ini_key() {
    # set_ini_key file Key value  (replaces all Key= lines)
    local file=$1 key=$2 value=$3
    [[ -f "$file" ]] || return 0
    if grep -qE "^${key}=" "$file" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$file"
    else
        # append under [General] if present, else end of file
        if grep -q '^\[General\]' "$file"; then
            sed -i "/^\[General\]/a ${key}=${value}" "$file"
        else
            printf '%s=%s\n' "$key" "$value" >>"$file"
        fi
    fi
}

apply_wallpaper() {
    local wall=$1
    [[ -f "$wall" ]] || { log "Wallpaper missing: $wall"; return 1; }

    if [[ -f "$HYPRPAPER_CONF" ]]; then
        # Replace path = ... line(s)
        if grep -qE '^\s*path\s*=' "$HYPRPAPER_CONF"; then
            sed -i "s|^\(\s*path\s*=\s*\).*|\1${wall}|" "$HYPRPAPER_CONF"
        fi
    fi

    # Live IPC if hyprpaper is running
    if command -v hyprctl >/dev/null 2>&1; then
        if hyprctl hyprpaper wallpaper ",${wall}" >/dev/null 2>&1; then
            return 0
        fi
    fi
    # Fallback: restart hyprpaper (close lock fd so we don't hold the flock)
    killall hyprpaper 2>/dev/null || true
    hyprpaper >/dev/null 2>&1 9>&- &
}

apply_waybar_colors() {
    local mode=$1
    [[ -f "$WAYBAR_STYLE" ]] || return 0
    if [[ "$mode" == "dark" ]]; then
        replace_in "$WAYBAR_STYLE" "@define-color window_bg #c9d6e5;" "@define-color window_bg #3B4252;"
        replace_in "$WAYBAR_STYLE" "@define-color center_bg #c9d5e5;" "@define-color center_bg #3B4252;"
        replace_in "$WAYBAR_STYLE" "@define-color light #dde1e8;" "@define-color light #4C566A;"
        replace_in "$WAYBAR_STYLE" "@define-color text_dark #2E3440;" "@define-color text_dark #ECEFF4;"
        # also handle already-dark → light reverse paths handled in light branch
    else
        replace_in "$WAYBAR_STYLE" "@define-color window_bg #3B4252;" "@define-color window_bg #c9d6e5;"
        replace_in "$WAYBAR_STYLE" "@define-color center_bg #3B4252;" "@define-color center_bg #c9d5e5;"
        replace_in "$WAYBAR_STYLE" "@define-color light #4C566A;" "@define-color light #dde1e8;"
        replace_in "$WAYBAR_STYLE" "@define-color text_dark #ECEFF4;" "@define-color text_dark #2E3440;"
    fi
}

apply_kitty() {
    local mode=$1
    local theme_file="${HOME}/.config/kitty/nord-${mode}.conf"
    [[ -f "$theme_file" && -f "$KITTY_CONF" ]] || return 0

    # Sync every color key from nord-{light,dark}.conf into kitty.conf.
    # (Previously only fg/bg changed, so yellow/magenta stayed unreadable on light.)
    local key val
    while read -r key val; do
        [[ -z "${key:-}" || "$key" == \#* ]] && continue
        case "$key" in
            foreground|background|cursor|cursor_text_color|selection_foreground|selection_background|color[0-9]|color1[0-5])
                if grep -qE "^${key}[[:space:]]" "$KITTY_CONF" 2>/dev/null; then
                    sed -i -E "s|^${key}[[:space:]]+.*|${key} ${val}|" "$KITTY_CONF"
                else
                    # Append missing keys near the end of the color section
                    printf '%s %s\n' "$key" "$val" >>"$KITTY_CONF"
                fi
                ;;
        esac
    done < <(grep -E '^(foreground|background|cursor|cursor_text_color|selection_foreground|selection_background|color[0-9]+)[[:space:]]' "$theme_file")

    # Live reload (SIGUSR1 only — never `kitty @`, which can hang).
    killall -SIGUSR1 kitty 2>/dev/null || true
}

apply_rofi() {
    local mode=$1
    [[ -f "$ROFI_CONF" ]] || return 0
    if [[ "$mode" == "dark" ]]; then
        replace_in "$ROFI_CONF" "nord-light.rasi" "nord-dark.rasi"
    else
        replace_in "$ROFI_CONF" "nord-dark.rasi" "nord-light.rasi"
    fi
}

apply_hyprland_files() {
    local mode=$1
    local gtk qt scheme active inactive bg_color

    if [[ "$mode" == "dark" ]]; then
        gtk="Adwaita:dark"
        qt="Adwaita-Dark"
        scheme="prefer-dark"
        active="rgba(88c0d0ff)"
        inactive="rgba(4c566aff)"
        bg_color="0x2e3440"
    else
        gtk="Adwaita:light"
        qt="Adwaita-Light"
        scheme="prefer-light"
        active="rgba(5e81acff)"
        inactive="rgba(d8dee9ff)"
        bg_color="0xeceff4"
    fi

    # Lua config (desktop). Use '#' delimiter so '|' in regex alternation is safe.
    if [[ -f "$HYPRLAND_LUA" ]]; then
        sed -i -E \
            -e "s#hl\\.env\\(\"GTK_THEME\", \"Adwaita:(light|dark)\"\\)#hl.env(\"GTK_THEME\", \"${gtk}\")#" \
            -e "s#hl\\.env\\(\"QT_STYLE_OVERRIDE\", \"Adwaita-(Light|Dark)\"\\)#hl.env(\"QT_STYLE_OVERRIDE\", \"${qt}\")#" \
            -e "s#hl\\.env\\(\"COLOR_SCHEME\", \"prefer-(light|dark)\"\\)#hl.env(\"COLOR_SCHEME\", \"${scheme}\")#" \
            -e "s#\\[\"col\\.active_border\"\\] = \"rgba\\([0-9a-fA-F]+\\)\"#[\"col.active_border\"] = \"${active}\"#" \
            -e "s#\\[\"col\\.inactive_border\"\\] = \"rgba\\([0-9a-fA-F]+\\)\"#[\"col.inactive_border\"] = \"${inactive}\"#" \
            -e "s#background_color = \"0x[0-9a-fA-F]+\"#background_color = \"${bg_color}\"#" \
            "$HYPRLAND_LUA"
        if [[ "$mode" == "dark" ]]; then
            sed -i 's/Solid Nord-light fill/Solid Nord-dark fill/' "$HYPRLAND_LUA" 2>/dev/null || true
        else
            sed -i 's/Solid Nord-dark fill/Solid Nord-light fill/' "$HYPRLAND_LUA" 2>/dev/null || true
        fi
    fi

    # Classic conf (laptop / legacy)
    if [[ -f "$HYPRLAND_CONF" ]]; then
        sed -i -E \
            -e "s#env = GTK_THEME,Adwaita:(light|dark)#env = GTK_THEME,${gtk}#" \
            -e "s#env = QT_STYLE_OVERRIDE,Adwaita-(Light|Dark)#env = QT_STYLE_OVERRIDE,${qt}#" \
            -e "s#env = COLOR_SCHEME,prefer-(light|dark)#env = COLOR_SCHEME,${scheme}#" \
            -e "s#col\\.active_border = rgba\\([0-9a-fA-F]+\\)#col.active_border = ${active}#" \
            -e "s#col\\.inactive_border = rgba\\([0-9a-fA-F]+\\)#col.inactive_border = ${inactive}#" \
            "$HYPRLAND_CONF"
    fi

    # Live keywords (no full hyprland reload needed for borders/bg)
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl keyword general:col.active_border "$active" >/dev/null 2>&1 || true
        hyprctl keyword general:col.inactive_border "$inactive" >/dev/null 2>&1 || true
        hyprctl keyword misc:background_color "$bg_color" >/dev/null 2>&1 || true
        # Env for newly launched apps in this session
        hyprctl keyword env "GTK_THEME,${gtk}" >/dev/null 2>&1 || true
        hyprctl keyword env "QT_STYLE_OVERRIDE,${qt}" >/dev/null 2>&1 || true
        hyprctl keyword env "COLOR_SCHEME,${scheme}" >/dev/null 2>&1 || true
    fi
}

apply_gsettings() {
    local mode=$1
    command -v gsettings >/dev/null 2>&1 || return 0
    if [[ "$mode" == "dark" ]]; then
        gsettings set org.gnome.desktop.interface color-scheme prefer-dark 2>/dev/null || true
        gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark 2>/dev/null || true
    else
        gsettings set org.gnome.desktop.interface color-scheme prefer-light 2>/dev/null || true
        gsettings set org.gnome.desktop.interface gtk-theme Adwaita 2>/dev/null || true
    fi
}

apply_mako() {
    local mode=$1
    local src="${THEMES_DIR}/mako-${mode}"
    [[ -f "$src" ]] || return 0
    mkdir -p "$(dirname "$MAKO_CONF")"
    cp "$src" "$MAKO_CONF"
    if command -v makoctl >/dev/null 2>&1; then
        makoctl reload 2>/dev/null || true
    else
        killall mako 2>/dev/null || true
        mako >/dev/null 2>&1 9>&- &
    fi
}

apply_discord_css() {
    local mode=$1
    local src="${THEMES_DIR}/quickcss-${mode}.css"
    [[ -f "$src" ]] || return 0
    for dest in "$VESKTOP_CSS" "$EQUIBOP_CSS"; do
        if [[ -d "$(dirname "$dest")" ]]; then
            cp "$src" "$dest"
            # Touch so Vencord/Vesktop picks up mtime change
            touch "$dest"
        fi
    done
}

apply_vscode() {
    local mode=$1
    [[ -f "$VSCODE_SETTINGS" ]] || return 0
    # Built-in VS Code 2026 themes (currently installed as Light 2026)
    local theme
    if [[ "$mode" == "dark" ]]; then
        theme="Dark 2026"
    else
        theme="Light 2026"
    fi
    set_json_string "$VSCODE_SETTINGS" "workbench.colorTheme" "$theme"
}

apply_prism() {
    local mode=$1
    [[ -f "$PRISM_CFG" ]] || return 0
    # Prism built-ins: system | dark | bright
    if [[ "$mode" == "dark" ]]; then
        set_ini_key "$PRISM_CFG" "ApplicationTheme" "dark"
    else
        set_ini_key "$PRISM_CFG" "ApplicationTheme" "bright"
    fi
}

apply_firefox() {
    # Nord Light & Dark follows OS color-scheme live via xdg-desktop-portal,
    # driven by apply_gsettings (org.gnome.desktop.interface color-scheme).
    #
    # Never write ui.systemUsesDarkTheme into user.js:
    #   - 0/1 locks the scheme at startup and blocks live portal updates
    #   - -1 can also stick as a user pref and confuse cold starts
    # If a prior pin exists, strip it so gsettings can drive the dual theme.
    [[ -n "${FF_PREFS:-}" ]] || return 0

    if [[ -f "$FF_PREFS" ]] && grep -q 'ui.systemUsesDarkTheme' "$FF_PREFS" 2>/dev/null; then
        sed -i -E '/ui\.systemUsesDarkTheme/d; /Managed by theme_toggle\.sh.*Firefox|Managed by theme_toggle\.sh.*follow OS/d' "$FF_PREFS"
        # Drop user.js entirely if it only held our managed pref
        if [[ -f "$FF_PREFS" ]] && ! grep -q '[^[:space:]]' "$FF_PREFS" 2>/dev/null; then
            rm -f "$FF_PREFS"
        fi
    fi

    # Clear a stale pin from prefs.js only when Firefox is not running
    # (while running it owns prefs.js and would overwrite us on shutdown).
    if [[ -n "${FF_PROFILE_DIR:-}" && -f "${FF_PROFILE_DIR}/prefs.js" ]]; then
        if ! pgrep -x firefox >/dev/null 2>&1; then
            sed -i -E '/user_pref\("ui\.systemUsesDarkTheme"/d' "${FF_PROFILE_DIR}/prefs.js" 2>/dev/null || true
        fi
    fi
}

# Dolphin / other KF6 apps — write Nord color scheme + Breeze icons only.
# Never kill/reopen Dolphin: open windows may keep the old palette until the
# user restarts them themselves (preferred over interrupting file browsing).
apply_dolphin() {
    local mode=$1
    local scheme icon
    if [[ "$mode" == "dark" ]]; then
        scheme="NordDark"
        icon="breeze-dark"
    else
        scheme="NordLight"
        icon="breeze"
    fi

    if [[ ! -f "${COLOR_SCHEMES_DIR}/${scheme}.colors" ]]; then
        log "Missing color scheme: ${COLOR_SCHEMES_DIR}/${scheme}.colors"
        return 0
    fi

    mkdir -p "$(dirname "$KDEGLOBALS")"

    if command -v kwriteconfig6 >/dev/null 2>&1; then
        kwriteconfig6 --file kdeglobals --group General --key ColorScheme "$scheme"
        kwriteconfig6 --file kdeglobals --group KDE --key ColorScheme "$scheme"
        kwriteconfig6 --file kdeglobals --group Icons --key Theme "$icon"
    else
        if [[ ! -f "$KDEGLOBALS" ]]; then
            printf '[General]\nColorScheme=%s\n\n[Icons]\nTheme=%s\n' "$scheme" "$icon" >"$KDEGLOBALS"
        else
            if grep -q '^ColorScheme=' "$KDEGLOBALS" 2>/dev/null; then
                sed -i "s|^ColorScheme=.*|ColorScheme=${scheme}|" "$KDEGLOBALS"
            else
                printf '\n[General]\nColorScheme=%s\n' "$scheme" >>"$KDEGLOBALS"
            fi
            if grep -qE '^\[Icons\]' "$KDEGLOBALS" 2>/dev/null; then
                sed -i "/^\[Icons\]/,/^\[/{s|^Theme=.*|Theme=${icon}|}" "$KDEGLOBALS"
            else
                printf '\n[Icons]\nTheme=%s\n' "$icon" >>"$KDEGLOBALS"
            fi
        fi
    fi

    # Best-effort notify (signal only — never restarts apps, never waits for reply)
    if command -v dbus-send >/dev/null 2>&1; then
        dbus-send --session --type=signal /KGlobalSettings \
            org.kde.KGlobalSettings.notifyChange int32:0 int32:0 \
            2>/dev/null || true
    fi
}

restart_waybar() {
    # 9>&- : must not inherit flock fd
    killall waybar 2>/dev/null || true
    waybar >/dev/null 2>&1 9>&- &
}

notify_theme() {
    local mode=$1
    local label
    if [[ "$mode" == "dark" ]]; then
        label="Nord Dark"
    else
        label="Nord Light"
    fi
    if command -v notify-send >/dev/null 2>&1; then
        # Replace previous theme notification if still visible
        notify-send -a theme -u low -r 99112 -t 2000 "Theme" "Switched to ${label}" 2>/dev/null \
            || notify-send -a theme -u low -t 2000 "Theme" "Switched to ${label}" 2>/dev/null \
            || true
    fi
}

apply_theme() {
    local mode=$1
    local wall

    # Commit state immediately so a second press (if any) sees the new mode
    printf '%s\n' "$mode" >"$STATE_FILE"

    if [[ "$mode" == "dark" ]]; then
        wall=$(read_wall "$DARK_WALL_FILE" "$DEFAULT_DARK_WALL")
        log "Switching to Dark Theme (Nord)..."
    else
        wall=$(read_wall "$LIGHT_WALL_FILE" "$DEFAULT_LIGHT_WALL")
        log "Switching to Light Theme (Nord)..."
    fi

    apply_wallpaper "$wall"
    apply_waybar_colors "$mode"
    apply_kitty "$mode"
    apply_rofi "$mode"
    apply_hyprland_files "$mode"
    apply_gsettings "$mode"
    apply_dolphin "$mode"
    apply_mako "$mode"
    apply_discord_css "$mode"
    apply_vscode "$mode"
    apply_prism "$mode"
    apply_firefox "$mode"
    restart_waybar
    notify_theme "$mode"

    log "Theme toggled → ${mode}"
}

# --- main: exclusive lock + short cooldown ---
# Prevents double Super+Z from undoing itself. Background children MUST use
# 9>&- so they never inherit this flock.
mkdir -p "$(dirname "$LOCK_FILE")" 2>/dev/null || true
exec 9>"$LOCK_FILE"
if ! flock -n 9; then
    exit 0
fi

if [[ -f "${LOCK_FILE}.ran" ]]; then
    ran_m=$(stat -c %Y "${LOCK_FILE}.ran" 2>/dev/null || echo 0)
    age=$(( $(date +%s) - ran_m ))
    if (( age < 1 )); then
        exit 0
    fi
fi

CUR=$(current_theme)
if [[ "$CUR" == "light" ]]; then
    apply_theme "dark"
else
    apply_theme "light"
fi

date +%s >"${LOCK_FILE}.ran"
# Release immediately — do not sleep while holding the lock.
flock -u 9 2>/dev/null || true

