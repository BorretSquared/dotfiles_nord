-- #####################
-- ### HYPRLAND CONF ###
-- #####################

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
    scale = "1.33"
})

-----------------------------
--- ENVIRONMENT VARIABLES ###
-----------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Light theme configuration
hl.env("GTK_THEME", "Adwaita:light")
hl.env("QT_STYLE_OVERRIDE", "Adwaita-Light")
hl.env("COLOR_SCHEME", "prefer-light")
hl.env("LC_TIME", "en_GB.UTF-8")


----------------------
--- AUTOSTART ########
----------------------

hl.on("hyprland.start", function()
    -- Plugins
    hl.exec_cmd("hyprpm reload -n || (hyprpm update -n && hyprpm reload -n)")
    
    -- Delay plugin configuration slightly to ensure hyprpm has finished mounting them.
    -- Updated to use the new 'gaps_in' and 'gaps_out' keys from the sandwichfarm fork
    hl.exec_cmd([[bash -c 'sleep 2 && \
        hyprctl keyword plugin:hyprexpo:columns 3 && \
        hyprctl keyword plugin:hyprexpo:gaps_in 5 && \
        hyprctl keyword plugin:hyprexpo:gaps_out 5 && \
        hyprctl keyword plugin:hyprexpo:bg_col "rgb(111111)" && \
        hyprctl keyword plugin:hyprexpo:workspace_method "first 1"']])

    -- UI and applications
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("waybar")
    hl.exec_cmd("dunst")

    -- Custom scripts
    hl.exec_cmd('bash -c "while true; do ~/.config/hypr/scripts/battery_notify.sh; sleep 300; done"')
    hl.exec_cmd("~/.local/bin/start-lock-services.sh")

    -- KDE Connect
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
        enable_anr_dialog = false
    },
    dwindle = {
        preserve_split = true
    },
    master = {
        new_status = "master"
    },
    input = {
        kb_layout = "apt,apt_de,us",
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

hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("easeOutCubic", { type = "bezier", points = { {0.33, 1}, {0.68, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0}, {0.35, 1} } })
hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0}, {0.75, 1} } })
hl.curve("quick", { type = "bezier", points = { {0.15, 0}, {0.1, 1} } })

hl.animation({ leaf = "global", enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "windows", enabled = true, speed = 2, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "easeOutCubic" })
hl.animation({ leaf = "border", enabled = true, speed = 2, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2, bezier = "easeOutCubic" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1, bezier = "easeOutCubic" })
hl.animation({ leaf = "fade", enabled = true, speed = 2, bezier = "easeOutCubic" })
hl.animation({ leaf = "layers", enabled = true, speed = 2, bezier = "easeOutCubic" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 2, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 2, bezier = "easeOutCubic" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1, bezier = "easeOutCubic" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 3, bezier = "easeOutCubic", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 2, bezier = "easeOutCubic", style = "slide" })


----------------------
--- KEYBINDINGS ######
----------------------

-- Application launchers
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(firefox))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("equibop"))
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("~/.config/hypr/scripts/theme_toggle.sh"))

-- Window management
hl.bind(mainMod .. " + M", hl.dsp.window.close()) 
hl.bind(mainMod .. " + H", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + P", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + Y", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + N", hl.dsp.layout("togglesplit"))

-- Workspace navigation
-- Workspace navigation
hl.bind(mainMod .. " + grave", function()
    hl.plugin.hyprexpo.expo("toggle")
end)
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.exec_cmd("~/.config/hypr/scripts/next_workspace.sh"))
hl.bind(mainMod .. " + CTRL + TAB", hl.dsp.exec_cmd("~/.config/hypr/scripts/prev_workspace.sh"))

for i = 1, 9 do
    hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Focus navigation
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Move windows
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Resize windows
hl.bind(mainMod .. " + CTRL + left", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))

-- Mouse scrolling & window management
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshot utilities
hl.bind("Print", hl.dsp.exec_cmd('grim -s 1.33 -g "$(slurp)" - | wl-copy'))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -s 1.33 -g "$(slurp)" - | wl-copy'))

-- Utilities
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("~/.config/hypr/scripts/toggle_screen_timeout.sh"))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("~/.config/hypr/scripts/keyboard_layout_notify.sh"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("hyprlock --grace 0"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("~/.config/hypr/scripts/power_menu.sh"))
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("~/.config/hypr/scripts/power_menu.sh"), { locked = true })
hl.bind(mainMod .. " + less", hl.dsp.exit())

-- Media & System controls
hl.bind("ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ && ~/.config/hypr/scripts/volume_notify.sh"), { repeating = true, locked = true })
hl.bind("ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && ~/.config/hypr/scripts/volume_notify.sh"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && ~/.config/hypr/scripts/volume_notify.sh"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+ && ~/.config/hypr/scripts/brightness_notify.sh"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%- && ~/.config/hypr/scripts/brightness_notify.sh"), { repeating = true, locked = true })

-- Player controls
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause",             hl.dsp.exec_cmd("~/.config/hypr/scripts/airpods_double_tap.sh"), { locked = true })
hl.bind("XF86AudioPlay",              hl.dsp.exec_cmd("~/.config/hypr/scripts/airpods_double_tap.sh"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("ALT_R + XF86AudioPause", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("ALT_R + XF86AudioPlay", hl.dsp.exec_cmd("playerctl next"), { locked = true })


----------------------
--- WINDOW RULES #####
----------------------

hl.window_rule({
    match = { class = ".*" },
    suppress_event = "maximize"
})

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

hl.window_rule({
    match = { class = "^(kitty)$" },
    opacity = "0.85 0.85"
})

hl.window_rule({
    match = { class = "^(Dunst)$" },
    border_size = 0,
    no_blur = true,
    no_anim = true,
    float = true
})

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