# Host overlays

Copy the files for the machine you are on over the shared `.config/hypr/` defaults after linking.

## laptop (Surface)

```bash
cp hosts/laptop/hyprland.conf  ~/.config/hypr/hyprland.conf
cp hosts/laptop/hyprpaper.conf ~/.config/hypr/hyprpaper.conf
# optional lua snapshot: hosts/laptop/hyprland.lua
```

- scale 1.33, monitor eDP-1
- Super+B → equibop
- exec-once dunst

## desktop

```bash
cp hosts/desktop/hyprland.lua   ~/.config/hypr/hyprland.lua
cp hosts/desktop/hyprpaper.conf ~/.config/hypr/hyprpaper.conf
# merge zprofile INTEL_DEBUG into ~/.zprofile if needed
```

- scale 1.25, all monitors
- Super+B → vesktop
- mako, OpenRGB helpers, INTEL_DEBUG=noccs
