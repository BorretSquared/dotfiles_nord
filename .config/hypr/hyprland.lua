-- #####################
-- ### HYPRLAND CONF ###
-- #####################
-- Desktop config - converted from hyprland.conf
-- Reference: laptop lua config (hyprland.lua)

----------------------
--- VARIABLES ########
----------------------

local terminal = "kitty"
local fileManager = "dolphin"
local menu = "wofi --show drun"
local firefox = "firefox"
local mainMod = "SUPER"


----------------------
--- MONITORS #########
----------------------

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = "1.25"
})


----------------------
--- DEVICE RULES #####
----------------------

hl.device({
    name = "keychron-keychron-k2",
    kb_options = "altwin:swap_alt_win"
})

-----------------------------
--- ENVIRONMENT VARIABLES ###
-----------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- XDG Desktop Portal
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Light theme configuration
hl.env("GTK_THEME", "Adwaita:light")
hl.env("QT_STYLE_OVERRIDE", "Adwaita-Light")
hl.env("COLOR_SCHEME", "prefer-light")

-- Intel Arc A770 - disable DRM modifiers/CCS for screencopy DMA-BUF compatibility
hl.env("INTEL_DEBUG", "noccs")


----------------------
--- AUTOSTART ########
----------------------

hl.on("hyprland.start", function()
    -- Critical path first: env + wallpaper/bar so the desktop appears ASAP.
    -- Do NOT restart pipewire here — systemd --user already starts it, and
    -- restarting right at login races Hyprland's first frames for ~2s.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP INTEL_DEBUG")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP INTEL_DEBUG")

    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")

    -- Portals: ensure xdph is up without blocking first paint
    hl.exec_cmd([[bash -c '
        systemctl --user start xdg-desktop-portal-hyprland.service xdg-desktop-portal.service 2>/dev/null \
          || (killall xdg-desktop-portal-hyprland xdg-desktop-portal 2>/dev/null;
              /usr/lib/xdg-desktop-portal-hyprland &
              sleep 1;
              /usr/lib/xdg-desktop-portal &)
    ']])

    -- Plugins: defer so they never compete with first frame / DRM init
    hl.exec_cmd([[bash -c '
        sleep 3
        hyprpm reload || (hyprpm update && hyprpm reload)
        sleep 1
        hyprctl keyword plugin:hyprexpo:columns 3
        hyprctl keyword plugin:hyprexpo:gaps_in 5
        hyprctl keyword plugin:hyprexpo:gaps_out 5
        hyprctl keyword plugin:hyprexpo:bg_col "rgb(111111)"
        hyprctl keyword plugin:hyprexpo:workspace_method "first 1"
    ']])

    -- Non-critical background services
    hl.exec_cmd('bash -c "while true; do ~/.config/hypr/scripts/battery_notify.sh; sleep 300; done"')
    hl.exec_cmd("~/.local/bin/start-lock-services.sh")
    hl.exec_cmd("/usr/bin/kdeconnectd")
    hl.exec_cmd("/usr/bin/kdeconnect-indicator")
end)


----------------------
--- CONFIG BLOCK #####
----------------------

hl.config({
    render = {
        direct_scanout = false
    },
    general = {
        gaps_in = 5,
        gaps_out = 6,
        border_size = 2,
        ["col.active_border"] = "rgba(5e81acff)",
        ["col.inactive_border"] = "rgba(d8dee9ff)",
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle"
    },
    decoration = {
        rounding = 6,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 8,
            render_power = 3,
            color = "rgba(2e344088)"
        },
        blur = {
            enabled = true,
            size = 6,
            passes = 1,
            ignore_opacity = true,
            xray = true,
            vibrancy = 0.15
        }
    },
    animations = {
        enabled = true
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        -- Solid Nord-light fill until hyprpaper paints — avoids black/TTY flash
        background_color = "0xeceff4",
        enable_anr_dialog = false
    },
    dwindle = {
        preserve_split = true
    },
    master = {
        new_status = "master"
    },
    input = {
        kb_layout = "apt",
        resolve_binds_by_sym = 1,
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = true
        }
    },
    xwayland = {
        force_zero_scaling = true
    }
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5
})


----------------------
--- CURVES & ANIM ####
----------------------

hl.curve("easeOutQuint",    { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("easeOutCubic",   { type = "bezier", points = { {0.33, 1}, {0.68, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0}, {0.35, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},    {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0},  {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0}, {0.1, 1}  } })

hl.animation({ leaf = "global",        enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "windows",       enabled = true, speed = 2, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 2, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 2, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 2, bezier = "easeOutCubic" })
hl.animation({ leaf = "border",        enabled = true, speed = 2, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 2, bezier = "easeOutCubic" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1, bezier = "easeOutCubic" })
hl.animation({ leaf = "fade",          enabled = true, speed = 2, bezier = "easeOutCubic" })
hl.animation({ leaf = "layers",        enabled = true, speed = 2, bezier = "easeOutCubic" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 2, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 2, bezier = "easeOutCubic" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1, bezier = "easeOutCubic" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 3, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 3, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2, bezier = "easeOutCubic", style = "slide" })


----------------------
--- KEYBINDINGS ######
----------------------

-- Application launchers
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(firefox))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("vesktop"))

-- Window management
hl.bind(mainMod .. " + M", hl.dsp.window.close())
hl.bind(mainMod .. " + H", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Y", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + N", hl.dsp.layout("togglesplit"))

hl.bind(mainMod .. " + grave", function() hl.plugin.hyprexpo.expo("toggle") end)
hl.bind(mainMod .. " + TAB",            hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + SHIFT + TAB",   hl.dsp.exec_cmd("~/.config/hypr/scripts/next_workspace.sh"))
hl.bind(mainMod .. " + CTRL + TAB",    hl.dsp.exec_cmd("~/.config/hypr/scripts/prev_workspace.sh"))

for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i,   hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0",         hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Focus navigation
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Move windows
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Resize windows
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -20, y = 0,   relative = true }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 20,  y = 0,   relative = true }))
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0,   y = -20, relative = true }))
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0,   y = 20,  relative = true }))

-- Mouse workspace scrolling & window management
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- Screenshot utilities
hl.bind("Print",                    hl.dsp.exec_cmd('grim -s 1.33 -g "$(slurp)" - | wl-copy'))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -s 1.33 -g "$(slurp)" - | wl-copy'))

-- Utilities
hl.bind(mainMod .. " + X",      hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle_screen_timeout.sh"))
hl.bind(mainMod .. " + Z",      hl.dsp.exec_cmd("~/.config/hypr/scripts/theme_toggle.sh"))
hl.bind(mainMod .. " + SPACE",  hl.dsp.exec_cmd("~/.config/hypr/scripts/keyboard_layout_notify.sh"))
hl.bind(mainMod .. " + A",      hl.dsp.exec_cmd("hyprlock --grace 0"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("~/.config/hypr/scripts/power_menu.sh"))
hl.bind("XF86PowerOff",         hl.dsp.exec_cmd("~/.config/hypr/scripts/power_menu.sh"), { locked = true })
hl.bind(mainMod .. " + less",   hl.dsp.exit())

-- Media & System controls
hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ && ~/.config/hypr/scripts/volume_notify.sh"),    { repeating = true, locked = true })
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && ~/.config/hypr/scripts/volume_notify.sh"),          { repeating = true, locked = true })
hl.bind("XF86AudioMute",              hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ~/.config/hypr/scripts/volume_notify.sh"),          { locked = true })
hl.bind("XF86AudioMicMute",           hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),                                                   { locked = true })
hl.bind("XF86MonBrightnessUp",        hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+ && ~/.config/hypr/scripts/brightness_notify.sh"),                  { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown",      hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%- && ~/.config/hypr/scripts/brightness_notify.sh"),                  { repeating = true, locked = true })

-- Player controls
hl.bind("XF86AudioNext",              hl.dsp.exec_cmd("playerctl next"),             { locked = true })
hl.bind("XF86AudioPause",             hl.dsp.exec_cmd("~/.config/hypr/scripts/airpods_double_tap.sh"), { locked = true })
hl.bind("XF86AudioPlay",              hl.dsp.exec_cmd("~/.config/hypr/scripts/airpods_double_tap.sh"), { locked = true })
hl.bind("XF86AudioPrev",              hl.dsp.exec_cmd("playerctl previous"),         { locked = true })
hl.bind("ALT_R + XF86AudioPause",    hl.dsp.exec_cmd("playerctl next"),             { locked = true })
hl.bind("ALT_R + XF86AudioPlay",     hl.dsp.exec_cmd("playerctl next"),             { locked = true })


----------------------
--- WINDOW RULES #####
----------------------

-- Default window behavior
hl.window_rule({
    match = { class = ".*" },
    suppress_event = "maximize"
})

-- Minecraft configuration
hl.window_rule({
    match = {
        class = "Minecraft",
        xwayland = true,
        fullscreen = true
    },
    float = true
})

hl.window_rule({
    match = { title = "Minecraft" },
    move = "0 0",
    size = "1536 1024"
})

-- Kitty transparency
hl.window_rule({
    match = { class = "^(kitty)$" },
    opacity = "0.85 0.85"
})

-- Dunst (notifications) styling
hl.window_rule({
    match = { class = "^(Dunst)$" },
    border_size = 0,
    no_blur = true,
    no_anim = true,
    float = true
})

-- Affinity and Wine application fixes
hl.window_rule({
    match = { class = "^(affinity\\.(exe|photo|designer|publisher))$" },
    no_blur = true,
    no_shadow = true,
    no_anim = true
})

hl.window_rule({
    match = { class = "^(wine)$" },
    no_blur = true,
    no_shadow = true
})

-- XWayland empty-class floating window focus fix
hl.window_rule({
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false
    },
    no_focus = true
})


----------------------
--- LAYER RULES ######
----------------------

hl.layer_rule({
    match = { namespace = "notifications" },
    animation = "slide"
})

hl.layer_rule({
    match = { namespace = "selection" },
    no_anim = true
})

hl.layer_rule({
    match = { namespace = "hyprpaper" },
    no_anim = true
})