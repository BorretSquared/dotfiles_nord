# Nord Dotfiles

Personal Hyprland + Nord setup, kept in sync with the **laptop** (Surface @ `192.168.0.26`) and **desktop** installs.

![Light wallpaper](backgrounds/GreatWallStairs.jpg)

## Machines

| Host | Hardware | Config style | Scale | Notes |
|------|----------|--------------|-------|-------|
| **laptop** (`borret`, Surface) | Surface kernel | `hyprland.conf` | `1.33` | Primary install; `.zshrc` + kitty often symlinked into this repo |
| **desktop** (`desktop`) | Intel Arc A770 | `hyprland.lua` | `1.25` | Clone of laptop stack; `INTEL_DEBUG=noccs`, OpenRGB GPU scripts, Vesktop |

Host-specific copies live under `hosts/{laptop,desktop}/`. Shared defaults live under `.config/`.

## Wallpaper

Light theme wallpaper is **`GreatWallStairs.jpg`** (not `light.png`).

Canonical paths used by the installs:

```text
~/Documents/backgrounds/GreatWallStairs.jpg   # light
~/Documents/backgrounds/misty_mountains.jpg   # dark (theme_toggle)
```

Repo copies are under `backgrounds/`. On setup, copy them into `~/Documents/backgrounds/`.

## Layout

```text
.config/
  hypr/          # hyprland.conf (laptop-style), hyprland.lua (desktop), scripts, lock/idle/paper
  waybar/        # bar + weather + optional cpu icon assets
  kitty/
  mako/          # desktop default notifier
  dunst/         # laptop theme_toggle notifier pair
  rofi/          # nord light/dark themes
  AirPodsTrayApp/          # LibrePods device conf (AirPods Pro 2)
  wireplumber/…/           # A2DP auto-profile + Bluetooth quality prefs
  systemd/user/            # optional airpods-monitor.service
  autostart/librepods.desktop
  sway/          # legacy
backgrounds/     # GreatWallStairs.jpg, dark.png, misty_mountains.jpg, …
hosts/
  laptop/        # hyprland.conf, hyprpaper (eDP-1), hyprland.lua snapshot
  desktop/       # hyprland.lua, hyprpaper (all monitors), zprofile (Intel)
.config/hypr/scripts/
  airpods_double_tap.sh    # custom stem double-tap → next (not LibrePods)
bin/
  airpods-connect.sh       # connect + force A2DP + set default sink
  fix-airpods              # recover when connected but silent
  bt-audio-mode            # range (SBC) vs quality (AAC)
  start-lock-services.sh
sddm/
  10-keyboard.conf         # APT as greeter default layout
  nord-light/              # greeter theme (also prefers APT in QML)
xkb_symbols/     # apt / apt_de layouts
.zshrc
```

## What was outdated (2026-07 analysis)

Compared live configs on **desktop** and **laptop** against this repo:

| Area | Repo (before) | Live installs |
|------|---------------|---------------|
| Wallpaper | `light.png` / DP-3 hardcode | `GreatWallStairs` via `~/Documents/backgrounds/` |
| Hyprland | Older `.conf`, many `*.bak`/`*.working` | Laptop: updated conf (portals, hyprexpo swipe, no ninjabrain bind); Desktop: full `hyprland.lua` |
| Notifications | Mixed dunst/mako | Laptop conf starts **dunst**; desktop lua starts **mako** |
| Rofi | Missing from repo | Present on both hosts with nord themes |
| Dunst themes | Missing | Present on laptop for theme_toggle |
| Waybar | Missing `cpu_icon` / `cpu_speed_icons` | Present on desktop (optional modules) |
| Scripts | No OpenRGB helpers | Desktop has `rgb-toggle.sh`, `gpu-rgb-off.sh` |
| Kitty | Empty nord theme stubs; no font pin | `font_family JetBrains Mono` |
| zsh | Older | Desktop and laptop PATH extensions (pipx, local bins) |
| Idle | hypridle conf present | Laptop has `start-lock-services.sh` + hypridle package; **desktop missing `hypridle` package** |

## Features

- Nord light (default) / dark toggle via `theme_toggle.sh` (Super+Z on laptop conf)
- Waybar with weather, workspaces, audio/cpu/mem/battery
- hyprlock + hypridle (dim → lock → DPMS)
- APTv3 keyboard (`xkb_symbols/apt`)
- Rofi app launcher (Super+T)
- Screenshot to clipboard via grim+slurp
- **AirPods Pro 2**: custom double-tap script + A2DP helpers (+ optional LibrePods tray)

## AirPods double-tap (custom script)

This is **not** a LibrePods feature. Both installs use a small custom Hyprland
script that you wrote for stem double-tap → skip track:

```text
~/.config/hypr/scripts/airpods_double_tap.sh
```

Repo path: `.config/hypr/scripts/airpods_double_tap.sh`.

### Why it exists

AirPods Pro stems only emit generic AVRCP media keys (`XF86AudioPlay` /
`XF86AudioPause`). A double stem-press looks like two play/pause events, so
without a debounce/timer script Linux cannot “skip track” the way iOS/macOS do.

### Behaviour (your script)

| Stem action | Result |
|-------------|--------|
| First press | Immediate `playerctl play-pause`; timestamp saved |
| Second press within **1000ms** | Undo the first play/pause, then `playerctl next` |
| Debug log | `/tmp/airpods_debug.log` |

Hyprland binds (conf + lua on both hosts):

```text
bindl = , XF86AudioPause, exec, ~/.config/hypr/scripts/airpods_double_tap.sh
bindl = , XF86AudioPlay,  exec, ~/.config/hypr/scripts/airpods_double_tap.sh
```

`ALT_R` + play/pause still maps to `playerctl next` as a keyboard fallback.

### Related AirPods helpers (separate from double-tap)

| Piece | Path | Role |
|-------|------|------|
| Double-tap script | `.config/hypr/scripts/airpods_double_tap.sh` | Custom stem double-tap → next |
| Connect helper | `bin/airpods-connect.sh` | `bluetoothctl connect` + A2DP + default sink |
| Silence fix | `bin/fix-airpods` | Restart WirePlumber / force A2DP |
| WirePlumber rule | `.config/wireplumber/.../51-airpods-fix.conf` | Prefer `a2dp-sink` for your MAC |
| LibrePods conf | `.config/AirPodsTrayApp/AirPodsTrayApp.conf` | Optional tray (ANC/battery); **not** double-tap |
| Autostart | `.config/autostart/librepods.desktop` | Optional tray launch |
| Quality toggle | `bin/bt-audio-mode` | `range` (SBC) vs `quality` (AAC) |

Device MAC in connect/fix/WirePlumber rules: **AirPods Pro 2** `6C:12:70:30:6C:B8`.
Update those files if you re-pair or change buds.

### Setup

```bash
sudo pacman -S playerctl bluez bluez-utils
systemctl --user enable --now mpris-proxy.service   # AVRCP media keys through to Hyprland

# Script (double-tap)
mkdir -p ~/.config/hypr/scripts
cp ~/dotfiles_nord/.config/hypr/scripts/airpods_double_tap.sh ~/.config/hypr/scripts/
chmod +x ~/.config/hypr/scripts/airpods_double_tap.sh
# ensure hyprland Play/Pause binds point at that path (see above), then:
hyprctl reload

# Optional connect/A2DP helpers
mkdir -p ~/.local/bin
ln -sfn ~/dotfiles_nord/bin/airpods-connect.sh ~/.local/bin/
ln -sfn ~/dotfiles_nord/bin/fix-airpods        ~/.local/bin/
ln -sfn ~/.local/bin/airpods-connect.sh        ~/.local/bin/airpods-connect
cp ~/dotfiles_nord/.config/wireplumber/wireplumber.conf.d/51-airpods-fix.conf \
   ~/.config/wireplumber/wireplumber.conf.d/
systemctl --user restart wireplumber

# Optional LibrePods tray only (ANC UI / battery — not double-tap)
# yay -S librepods
# cp AirPodsTrayApp conf + autostart if desired
```

## APT as default layout in the login manager (SDDM)

Goal: password entry on the greeter uses **APT**, not QWERTY.

### 1. Install the layout system-wide (once)

```bash
sudo cp ~/dotfiles_nord/xkb_symbols/apt    /usr/share/X11/xkb/symbols/apt
sudo cp ~/dotfiles_nord/xkb_symbols/apt_de /usr/share/X11/xkb/symbols/apt_de
```

Optional but recommended — make it the session default too:

```bash
localectl set-x11-keymap apt "" "" ""
# multi-layout (APT first, then apt_de, then us):
# edit /etc/X11/xorg.conf.d/00-keyboard.conf or use:
localectl set-x11-keymap apt,apt_de,us
```

### 2. Tell SDDM to start the greeter with APT first

```bash
sudo cp ~/dotfiles_nord/sddm/10-keyboard.conf /etc/sddm.conf.d/10-keyboard.conf
```

Contents:

```ini
[General]
GreeterEnvironment=XKB_DEFAULT_LAYOUT=apt,apt_de,us
```

This sets `XKB_DEFAULT_LAYOUT` for the greeter process. APT must already exist
under `/usr/share/X11/xkb/symbols/`.

### 3. Theme-side preference (nord-light)

`sddm/nord-light/Main.qml` includes `selectFavoredLayout()` which, on load,
picks a layout whose `shortName` is `apt` / `apt_v3` if the greeter exposes
multiple layouts. Keep this after theme reinstalls:

```bash
# example install path used by the theme scripts
sudo cp -a ~/dotfiles_nord/sddm/nord-light /usr/share/sddm/themes/
# and ensure Current=nord-light in /etc/sddm.conf or sddm/sddm.conf
```

### 4. Apply / verify

```bash
sudo systemctl restart sddm   # logs you out of the greeter; save work first
# At greeter: type a known APT-only key (e.g. letters that differ from QWERTY)
# or use the layout box in nord-light and confirm APT is selected
localectl status              # X11 Layout should list apt
```

### Troubleshooting

| Symptom | Fix |
|---------|-----|
| Greeter still QWERTY | Confirm `/usr/share/X11/xkb/symbols/apt` exists; restart SDDM |
| Layout missing from list | Greeter may only list layouts from `XKB_DEFAULT_LAYOUT` / system xkb rules — keep APT first in `10-keyboard.conf` |
| Session is APT but greeter is not | You only set `localectl` — still need `sddm/10-keyboard.conf` |
| Wayland greeter ignores env | This install uses `DisplayServer=x11-user` in `sddm.conf`; if you switch to pure Wayland greeter, re-test and prefer the QML `selectFavoredLayout` path |

## Dependencies

```text
hyprland hyprpaper hyprlock hypridle waybar kitty rofi mako dunst
grim slurp brightnessctl pipewire wireplumber playerctl
bluez bluez-utils
zsh zsh-autosuggestions zsh-syntax-highlighting fzf
```

Optional: `librepods` (AirPods tray/ANC), `openrgb` (desktop GPU RGB), KDE Connect, SDDM nord-light theme.

## Install / sync

```bash
git clone https://github.com/BorretSquared/dotfiles_nord.git ~/dotfiles_nord
cd ~/dotfiles_nord

# Wallpapers used by hyprpaper + theme_toggle
mkdir -p ~/Documents/backgrounds
cp backgrounds/GreatWallStairs.jpg backgrounds/misty_mountains.jpg \
   backgrounds/dark.png ~/Documents/backgrounds/

# Link shared configs (back up existing first)
ln -sfn "$(pwd)/.config/hypr"   ~/.config/hypr
ln -sfn "$(pwd)/.config/waybar" ~/.config/waybar
ln -sfn "$(pwd)/.config/kitty"  ~/.config/kitty
ln -sfn "$(pwd)/.config/mako"   ~/.config/mako
ln -sfn "$(pwd)/.config/rofi"   ~/.config/rofi
ln -sfn "$(pwd)/.zshrc"         ~/.zshrc

# AirPods helpers (double-tap lives under .config/hypr/scripts/ — see AirPods section)
ln -sfn "$(pwd)/bin/"* ~/.local/bin/ 2>/dev/null || true

# Host overlay
# laptop:
#   cp hosts/laptop/hyprland.conf  ~/.config/hypr/hyprland.conf
#   cp hosts/laptop/hyprpaper.conf ~/.config/hypr/hyprpaper.conf
# desktop (lua config is the active one):
#   cp hosts/desktop/hyprland.lua  ~/.config/hypr/hyprland.lua
#   cp hosts/desktop/hyprpaper.conf ~/.config/hypr/hyprpaper.conf
#   # optional: merge hosts/desktop/zprofile into ~/.zprofile for INTEL_DEBUG=noccs

chmod +x ~/.config/hypr/scripts/*.sh ~/.config/waybar/*.sh \
         ~/.config/waybar/custom_modules/*.sh bin/*.sh
mkdir -p ~/.local/bin
ln -sfn "$(pwd)/bin/start-lock-services.sh" ~/.local/bin/start-lock-services.sh
```

Install XKB symbols (once, as root):

```bash
sudo cp xkb_symbols/apt xkb_symbols/apt_de /usr/share/X11/xkb/symbols/
```

## Notes

- Keybinds assume **APTv3**, not QWERTY.
- Laptop scale **1.33**, desktop **1.25** — adjust `monitor` / grim `-s` if you change DPI.
- Theme toggle edits files in place; keep app configs writable (not read-only mounts).
- Firefox live theme switching is still incomplete.
- Prefer committing from one machine after deliberate sync; use `hosts/` for intentional machine diffs.

## License

None.
