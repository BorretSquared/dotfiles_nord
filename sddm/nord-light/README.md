# Nord Light SDDM Theme

A clean and modern SDDM login theme inspired by the Nord Light color palette, designed specifically for minimalist desktop environments like Hyprland, i3, sway, and other tiling window managers.

## Features

- **Nord Light Color Palette**: Carefully chosen colors that are easy on the eyes
- **Glassmorphism Design**: Modern translucent elements with subtle blur effects  
- **Animated Elements**: Floating geometric shapes for visual interest
- **Responsive Layout**: Adapts to different screen resolutions
- **Minimalist UI**: Clean, distraction-free login experience
- **Font Support**: Optimized for Inter font family
- **Keyboard Navigation**: Full support for tab navigation between elements

## Color Palette

The theme uses the complete Nord color palette, optimized for light backgrounds:

### Snow Storm (Light Colors)
- `#eceff4` - Primary background (nord6)
- `#e5e9f0` - Secondary background (nord5)  
- `#d8dee9` - UI elements (nord4)

### Polar Night (Dark Colors)
- `#2e3440` - Primary text (nord0)
- `#3b4252` - Secondary text (nord1)
- `#4c566a` - Subtle text (nord3)

### Frost (Blue Accents)
- `#5e81ac` - Primary accent (nord10)
- `#81a1c1` - Hover states (nord9)
- `#88c0d0` - Selection color (nord8)

### Aurora (Status Colors)
- `#a3be8c` - Success (nord14)
- `#bf616a` - Error/Shutdown (nord11)
- `#d08770` - Warning/Restart (nord12)

## Installation

**FIXED METHOD** - The install script now works correctly from the theme directory:

1. **Make sure you're in the theme directory:**
   ```bash
   cd ~/sddm-themes/nord-light
   ```

2. **Run the installation script:**
   ```bash
   sudo ./install.sh
   ```

3. **The script will:**
   - Copy theme files to `/usr/share/sddm/themes/nord-light`
   - Configure SDDM to use the new theme
   - Backup your existing SDDM configuration
   - Ask if you want to restart SDDM immediately

4. **To apply the theme immediately (this will log you out):**
   ```bash
   sudo systemctl restart sddm
   ```

## Customization

You can customize the theme by editing `theme.conf`:

```ini
[General]
background=path/to/your/background.png
```

## Requirements

- SDDM (Simple Desktop Display Manager)
- Qt 5.0 or higher
- QtQuick 2.0 or higher

## License

This theme is released under the MIT License.

## Compatibility

Designed and tested for:
- Arch Linux
- Hyprland window manager
- Nord Light desktop themes
- Modern displays (1920x1080 and higher)

The theme should work well with any Linux distribution using SDDM.
