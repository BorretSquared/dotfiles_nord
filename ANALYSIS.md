# Install vs Dotfiles Analysis (2026-07-16)

## Hosts surveyed

### desktop (this machine)
- **OS:** Arch Linux, kernel `7.1.2-arch3-1`, hostname `desktop`
- **Session:** Hyprland Wayland (running)
- **GPU:** Intel Arc A770 (`INTEL_DEBUG=noccs` for screencopy/portal DMA-BUF)
- **Monitor:** HDMI-A-1 Acer R221Q 1920x1080 @ ~75Hz, scale **1.25**
- **Active Hyprland config:** `~/.config/hypr/hyprland.lua` (no `hyprland.conf`)
- **Wallpaper (live):** was `dotfiles_nord/GreatWallStairs.jpg`; standardized to `Documents/backgrounds/GreatWallStairs.jpg`
- **Notifier:** mako
- **Chat:** Vesktop (Super+B)
- **Missing package vs laptop:** `hypridle` not installed
- **Desktop-only scripts:** `rgb-toggle.sh`, `gpu-rgb-off.sh` (OpenRGB)
- **Dotfiles link style:** mostly **copied** files, not symlinked (except historical waybar style backups)

### laptop (192.168.0.26, Surface)
- **OS:** Arch Linux Surface (`6.19.8-arch1-3-surface`), user `borret`
- **Session:** Hyprland (config present; hyprctl not available over plain SSH without session env)
- **Monitor:** eDP-1, scale **1.33** (Surface Laptop Go 2 class)
- **Active Hyprland config:** `~/.config/hypr/hyprland.conf` (also has `hyprland.lua` snapshot)
- **Wallpaper (live):** `Documents/backgrounds/GreatWallStairs.jpg` → repo now prefers `.png` name; high-res `.jpg` kept under `backgrounds/GreatWallStairs.jpg`
- **Notifier started by conf:** dunst (mako still installed)
- **Chat:** equibop (Super+B)
- **Symlinks into repo:** `~/.zshrc` → `dotfiles_nord/.zshrc`, `~/.config/kitty` → `dotfiles_nord/.config/kitty`
- **Extra:** hibernation tooling, `start-lock-services.sh`, dunst light/dark pair, older `Documents/dotfiles` tree (partial archive)

## Repo state before update

- Last meaningful commits: zsh/kitty/SDDM/XKB (~Apr 2026 local tree)
- Stale wallpaper: `light.png` (byte-identical to `GreatWallStairs.jpg`) and hyprpaper pointing at DP-3 + light.png
- Hyprland conf lagged laptop (missing portal setup, swipe hyprexpo; still had ninjabrain binds)
- No rofi, no dunst themes, no lua config, no host split, lots of backup files tracked
- Untracked `GreatWallStairs.jpg` already sitting in desktop clone

## Key deltas: laptop live vs old repo hyprland.conf

- Portal autostart + dbus env export for OBS/Equibop screenshare
- Pipewire left to systemd (commented exec-once)
- hyprexpo: native swipe + `hyprctl dispatch` instead of direct dispatcher
- Removed gesture_* plugin knobs that broke
- Removed ninjabrain window rules / Super+O bind
- `LC_TIME=en_GB.UTF-8`

## Key deltas: desktop vs laptop

| Topic | Laptop | Desktop |
|-------|--------|---------|
| Config format | `.conf` | `.lua` |
| Scale | 1.33 | 1.25 |
| Notifier | dunst | mako |
| Super+B | equibop | vesktop |
| Input layouts | apt,apt_de,us | apt only (lua) |
| Device rules | epic-mouse | + Keychron K2 alt/win swap |
| RGB | — | OpenRGB Arc A770 |
| INTEL_DEBUG | — | noccs (env + zprofile) |
| hypridle pkg | installed | **not installed** |

## Wallpaper decision

User directive: background must be **GreatWallStairs.jpg**, not light.png.

- `light.png` MD5 == `Documents/backgrounds/GreatWallStairs.jpg` (same image, wrong name)
- Repo now ships `backgrounds/GreatWallStairs.jpg` and hyprpaper/light_wallpaper/theme_toggle all use that name
- High-res 3840x2160 JPEG retained as `backgrounds/GreatWallStairs.jpg` for optional use

## Backup location

Created before any edits:

- Directory: `~/dotfiles_nord_backup_YYYYMMDD_HHMMSS`
- Tarball: same name with `.tar.gz`

## Recommended follow-ups (not done automatically)

1. Install `hypridle` on desktop and wire `start-lock-services.sh`
2. On laptop: copy `GreatWallStairs.jpg` into `Documents/backgrounds/` and update live hyprpaper when ready
3. Decide single notifier (mako vs dunst) long-term
4. Symlink desktop configs into the repo like laptop for easier two-way sync
5. Commit & push this repo update when you are happy with the tree

## Follow-up: AirPods double-press + SDDM APT (2026-07-16)

Added:
- Restored custom `~/.config/hypr/scripts/airpods_double_tap.sh` (from VS Code history; was missing on disk)
- Wired XF86AudioPlay/Pause to that script on both hosts
- AirPodsTrayApp conf, wireplumber A2DP rule, connect/fix scripts, bt-audio-mode
- `sddm/10-keyboard.conf` + README section for APT default on greeter
- Live desktop + laptop hyprland media binds updated
