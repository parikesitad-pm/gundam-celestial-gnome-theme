# Gundam Celestial GNOME Theme

[![Author](https://img.shields.io/badge/Author-parikesitad--pm-blue.svg)](#author--maintainer)
[![Manjaro Linux](https://img.shields.io/badge/Manjaro-26.1.2%20Bian--May-35bf5c?logo=manjaro&logoColor=white)](https://manjaro.org)
[![GNOME Shell](<https://img.shields.io/badge/GNOME-50.4%20(Wayland)-4a86cf?logo=gnome&logoColor=white>)](https://www.gnome.org)
[![Memory Strategy](<https://img.shields.io/badge/ZRAM-zstd%20(RAM%20size)-orange?logo=linux&logoColor=white>)](https://github.com/systemd/zram-generator)
[![Typography](https://img.shields.io/badge/Font-JetBrains%20Mono%2010-blueviolet.svg)](#typography--cursor-specifications)
[![Cursor](https://img.shields.io/badge/Cursor-MacOS%20Tahoe%2024px-lightgrey.svg)](#typography--cursor-specifications)
[![Zero-Blur](<https://img.shields.io/badge/Aesthetics-Flat%20RGBA%20(Zero--Blur)-cyan.svg>)](#flat-rgba-transparency--aesthetics-zero-blur-policy)
[![Preset](https://img.shields.io/badge/Preset-gundam--00-purple.svg)](#declarative-preset-management-gundam-00)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An automated, modular, and declarative dotfiles setup suite for Manjaro Linux (GNOME Shell 50.4 on Wayland), tailored for high-performance developer workstations constrained to 8GB physical RAM.

Inspired by **Mobile Suit Gundam 00: Celestial Being**, this profile blends macOS-style desktop aesthetics with an ultra-lean Linux architecture: zero background runtime daemons, native Wayland compliance, hardware-efficient dynamic wallpapers, pure SVG vector icon rendering, proactive zstd RAM compression, flat RGBA transparency (zero blur shaders), turnkey CLI animated installation, and atomic `dconf` preset management with rollback safety nets.

---

## Visual & Functional Specifications

| Component                   | Target Configuration                                                            | Technical Implementation                                                 |
| :-------------------------- | :------------------------------------------------------------------------------ | :----------------------------------------------------------------------- |
| **Window Controls**         | Left-aligned macOS buttons (`close,minimize,maximize:`)                         | `org.gnome.desktop.wm.preferences button-layout`                         |
| **Traffic Lights (GTK3/4)** | macOS red, yellow, and green circular window control buttons                    | WhiteSur GTK Dark theme + `~/.config/gtk-4.0/` & `gtk-3.0/` CSS          |
| **Firefox Browser Theme**   | Left-aligned macOS rounded buttons with Gundam colorway & GN green active tab   | `userChrome.css` + `user.js` in `~/.mozilla/firefox/*.default*`          |
| **Typography**              | JetBrains Mono (Interface, Monospace, Documents at 10pt)                        | `org.gnome.desktop.interface font-name 'JetBrains Mono 10'`              |
| **Cursor Theme**            | MacOS Tahoe (locked to compact 24px)                                            | `org.gnome.desktop.interface cursor-theme 'MacOS-Tahoe'`                 |
| **Spotlight Shortcut**      | Ulauncher application launcher mapped to `Ctrl + Space`                         | `~/.config/ulauncher/settings.json` + GNOME custom keybinding            |
| **Color Scheme**            | Prefer Dark                                                                     | `org.gnome.desktop.interface color-scheme 'prefer-dark'`                 |
| **GTK Application Theme**   | WhiteSur-Dark (macOS aesthetics)                                                | `org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark'`                  |
| **Dynamic Wallpaper**       | Gundam Celestial Being Dark & Light wallpapers (644 permissions)                | Native `org.gnome.desktop.background picture-uri-dark` & `picture-uri`   |
| **Lockscreen**              | Gundam Celestial Being Lockscreen (`zoom` mode, 644 permissions)                | `org.gnome.desktop.screensaver picture-uri` & `picture-uri-dark`         |
| **Icon Theme**              | `Nordzy-dark` (Pure SVG vector, 0MB RAM footprint)                              | `org.gnome.desktop.interface icon-theme 'Nordzy-dark'`                   |
| **Dock**                    | Bottom-centered, floating, autohide, 48px icons, workspace isolation            | `org.gnome.shell.extensions.dash-to-dock`                                |
| **Dock Controls**           | Click-to-minimize or preview, active app running indicators                     | `dash-to-dock click-action 'minimize-or-previews'` & `show-running true`  |
| **Dock Transparency**       | Pure static RGBA alpha (`0.45` opacity, `FIXED` mode, zero blur)                | `dash-to-dock transparency-mode 'FIXED'` & `background-opacity 0.45`     |
| **Top Bar Transparency**    | Flat RGBA semi-transparent alpha (`rgba(18, 22, 28, 0.45)`)                     | `user-theme` extension (`Gundam-Celestial`) + `gnome-shell.css`          |
| **Dock Overview Fix**       | Dock completely hides in Overview (`hide-in-overview true`)                     | `dconf: /org/gnome/shell/extensions/dash-to-dock/hide-in-overview`       |
| **Overview Search Bar**     | Search box disabled in Overview (Spotlight delegated to Ulauncher)              | `org.gnome.shell.extensions.just-perfection search false` + CSS          |
| **Top-Left Menu**           | Celestial Being logo (`cb.png`) replacing Activities button with macOS dropdown | `org.gnome.shell.extensions.logo-menu` (`logomenu@aryan_k`)              |
| **Resource Monitor**        | CPU and RAM usage strictly displayed to the right of center clock at 3000ms     | `org.gnome.shell.extensions.resource-monitor` (`Resource_Monitor@Ory0n`) |
| **Memory Strategy**         | ZRAM (`zstd`, `zram-size = ram`) + sysctl paging tuning                         | `zram-generator` + `/etc/sysctl.d/99-zram.conf`                          |
| **State Safety**            | Automated timestamped dconf snapshots with 1-command rollback                   | `~/.config/dconf-backup-*.dconf` + `./install.sh --restore`              |
| **Preset System**           | Atomic UI state import/export with dynamic path resolution                      | `presets/gundam-00.dconf` + `scripts/preset-manager.sh`                  |

---

## Typography & Cursor Specifications

- **Typography (JetBrains Mono)**:
  - System Interface: `JetBrains Mono 10`
  - Monospace / Terminal: `JetBrains Mono 10`
  - Document Typography: `JetBrains Mono 10`
  - Rendered with subpixel anti-aliasing and hinting enabled for maximum legibility on high-density displays.
- **Cursor (MacOS Tahoe)**:
  - Automatically fetched and registered directly to `~/.local/share/icons/MacOS-Tahoe/`.
  - Locked to **24px** size (`org.gnome.desktop.interface cursor-size 24`) for pixel-perfect macOS cursor proportions.

---

## Backup & Recovery Guide

The installation suite includes built-in safety nets to ensure your desktop environment can be audited before changes and rolled back instantly.

### 1. Automated Restore Point Creation

Every time `./install.sh` runs, it automatically creates a full atomic snapshot of your GNOME `dconf` configuration before mutating any visual settings:

- **Location**: `~/.config/dconf-backup-YYYYMMDD_HHMMSS.dconf`
- **Scope**: Full system desktop state capture.

### 2. Automated Instant Rollback (`--restore`)

If you want to revert all visual changes back to your original configuration, run:

```bash
./install.sh --restore
```

_The script automatically detects the latest snapshot file in `~/.config/` and reloads it cleanly via `dconf load /`._

### 3. Manual Fallback Recovery

You can also manually inspect and restore any specific historical snapshot:

```bash
# List all available backup snapshots
ls -lt ~/.config/dconf-backup-*.dconf

# Revert to a specific snapshot
dconf load / < ~/.config/dconf-backup-20260911_114231.dconf
```

### 4. Libadwaita CSS Collision Guard

To prevent broken rendering on systems with pre-existing custom GTK4 styles, the installer safeguards existing user stylesheets:

- Existing `~/.config/gtk-4.0/gtk.css` is safely renamed to `~/.config/gtk-4.0/gtk.css.bak.$(date +%s)`.
- Existing `~/.config/gtk-4.0/gtk-dark.css` is safely renamed to `~/.config/gtk-4.0/gtk-dark.css.bak.$(date +%s)`.

---

## macOS Traffic Lights Theming (GTK3 & GTK4/Libadwaita)

Authentic macOS circular red (`#ff5f56`), yellow (`#ffbd2e`), and green (`#27c93f`) window control buttons are rendered system-wide across all applications:

1. **GTK4 & Libadwaita Applications** (Nautilus File Manager, GNOME Settings, Text Editor, System Monitor):
   - Injected into `~/.config/gtk-4.0/gtk.css` and `~/.config/gtk-4.0/gtk-dark.css`.
   - Symlinks WhiteSur GTK-4.0 assets when installed, and provides standalone crisp vector SVG symbol overlays on hover (close, minimize, maximize) with active backdrop dimming.
   - Cleanly preserves default GNOME widget spacing without breaking app geometry.
2. **GTK3 Applications**:
   - Injected into `~/.config/gtk-3.0/gtk.css` and bound via `org.gnome.desktop.interface gtk-theme 'WhiteSur-Dark'`.

---

## Firefox macOS & Gundam Celestial Styling (`userChrome.css`)

Firefox is themed to harmonize with the desktop's macOS window geometry and Gundam Celestial Being aesthetic:

1. **Window Control Positioning & Pill Dots**:
   - Window control buttons (`close`, `minimize`, `maximize`) are placed on the left side of `#TabsToolbar` using flexbox reordering (`order: -1`).
   - Buttons are shaped as rounded circular dots (13px) with subtle vector hover icons.
2. **Exact Gundam Celestial Being Colorway**:
   - **Close**: Gundam Crimson Red (`#ED333B`)
   - **Minimize**: GN Solar Yellow (`#F6D32D`)
   - **Maximize**: Celestial Blue (`#1A5FB4`)
   - **Active Tab Line & Selection**: GN Particle Green (`#2EC27E`)
3. **Flat Dark Titlebar Integration**:
   - Tab bar and toolbox surfaces seamlessly blend into flat dark GTK surfaces (`rgba(18, 22, 28, 0.95)`).
4. **Automated User Profile Targeting**:
   - Deployed via `scripts/04-firefox.sh` across all active default profiles (`~/.mozilla/firefox/*.default*`).
   - Automatically enables legacy stylesheet loading in `user.js`:
     ```javascript
     user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
     user_pref("browser.tabs.drawInTitlebar", true);
     ```

---

## Flat RGBA Transparency & Aesthetics (Zero-Blur Policy)

To enforce a strict **8GB RAM zero-bloat constraint**, the workstation implements a **Zero-Blur Policy**:

- **No Blur Shaders**: Avoids heavy Gaussian blur compute overhead (such as Blur my Shell), saving hundreds of megabytes of GPU/VRAM and RAM while preventing compositor micro-stutters.
- **Dock Transparency**:
  - `transparency-mode = 'FIXED'`
  - `background-opacity = 0.45`
  - Floating aesthetic that blends smoothly with dynamic wallpapers.
- **Top Bar Alpha**:
  - GNOME top panel uses flat `rgba(18, 22, 28, 0.45)` with a subtle bottom border (`rgba(255, 255, 255, 0.08)`), applied via `user-theme` extension and `~/.config/gnome-shell/gnome-shell.css`.

---

## Clutter-Free Overview Mode

The GNOME Shell Activities Overview (triggered via the `Super` key) is optimized for zero visual distraction:

1. **Dock Collision Elimination**:
   - Dash to Dock is explicitly configured with `hide-in-overview = true`.
   - When entering the Overview, the dock immediately disappears, eliminating any dock overlapping or visual collision with the window spread.
2. **Search Bar Removal**:
   - The native GNOME Shell search input bar is hidden via `just-perfection` (`search = false`) and zero-daemon CSS.
   - App launching and searching is delegated to **Ulauncher** (macOS Spotlight style, mapped to `Ctrl + Space`), keeping the GNOME overview solely dedicated to clean window management.
3. **Native Window Spread**:
   - Preserves GNOME's native window clustering without installing heavy tiling or window-grouping daemons.

---

## Declarative Preset Management (`gundam-00`)

All desktop styling, extensions, and window behaviors are declaratively captured in `./presets/gundam-00.dconf`. The included `scripts/preset-manager.sh` utility manages applying, exporting, and backing up presets.

### Dynamic Absolute Path Tokenization

To ensure presets are 100% portable across different machines, user accounts, and clone directories, paths in `.dconf` files use the `@REPO_DIR@` token:

- When **applied**, `@REPO_DIR@` is dynamically replaced with the absolute repository path.
- When **exported**, the current active repository path is dynamically tokenized back into `@REPO_DIR@`.

### Available Commands

```bash
# Apply the default Gundam 00 preset
./scripts/preset-manager.sh apply gundam-00

# Snapshot your current desktop layout into a new preset
./scripts/preset-manager.sh export my-custom-preset

# List all available presets
./scripts/preset-manager.sh list
```

---

## Memory & Performance Strategy (8GB RAM Workstation)

Running modern developer workloads (IDEs, browser tabs, containerized toolchains) in an 8GB RAM envelope requires eliminating memory bloat at the root:

1. **ZRAM via `zram-generator`**:
   - `zram-size = ram`: Allocates a virtual swap device backed by compressed RAM equal to total physical RAM (~8GB).
   - `compression-algorithm = zstd`: High-throughput, multi-threaded real-time compression yielding an effective ~1.5x - 2.5x memory expansion.
   - `/etc/sysctl.d/99-zram.conf`:
     - `vm.swappiness = 180`: Actively migrates cold memory pages into compressed ZRAM instead of discarding disk caches or stalling under I/O pressure.
     - `vm.watermark_boost_factor = 0`: Minimizes allocation stalls caused by kernel memory compaction.
     - `vm.watermark_scale_factor = 125`: Ensures smooth, continuous background reclaim.
     - `vm.page-cluster = 0`: Disables multi-page swap readahead for single-page random access latency.
2. **Zero Runtime Daemons**:
   - No Electron wallpaper managers, external conky daemons, or Python status bars. All styling and extensions hook directly into GNOME Shell's native Wayland compositor (`mutter`).
3. **Pure Vector Assets**:
   - `Nordzy-dark` icon pack uses SVG vector definitions directly, preventing raster icon cache ballooning.
   - Resource Monitor explicitly disables GPU, disk, network, and temperature polling loops, strictly polling CPU and RAM every 3000ms.

---

## Repository Structure

```
gundam-celestial-gnome-theme/
├── install.sh                  # Turnkey orchestrator with animated loader & rollback engine
├── LICENSE                     # MIT License (c) 2026 parikesitad-pm
├── CHANGELOG.md                # Keep a Changelog standard release history
├── README.md                   # Production documentation & specifications
├── presets/
│   └── gundam-00.dconf         # Declarative UI state snapshot (@REPO_DIR@ tokenized)
├── scripts/
│   ├── 01-zram.sh             # ZRAM generator & sysctl memory optimizations
│   ├── 02-packages.sh         # Dependency resolution (Pacman + AUR/yay)
│   ├── 03-gnome-config.sh     # Gsettings, GTK-4.0 libadwaita links, wallpapers, UI tuning
│   ├── 04-firefox.sh          # Firefox macOS userChrome & Gundam styling
│   └── preset-manager.sh      # Declarative dconf manager (apply, export, list)
└── assets/
    └── img/
        ├── gundam-dark.jpg    # Dynamic dark wallpaper (1672x941)
        ├── gundam-light.jpg   # Dynamic light wallpaper (1670x941)
        ├── gundam-lock.jpg    # Lockscreen wallpaper (1672x941)
        └── logo/
            └── cb.png         # Celestial Being transparent PNG logo
```

---

## Requirements

- **Operating System**: Manjaro Linux 26.1.2 (Bian-May) or Arch Linux.
- **Desktop Environment**: GNOME Shell 50.4 on Wayland.
- **Privileges**: User account with `sudo` permissions (for ZRAM and pacman).
- **AUR Helper**: `yay` (recommended) or `paru`.

---

## Quickstart

Clone the repository and run the single-command turnkey installation script:

```bash
git clone https://github.com/parikesitad-pm/gundam-celestial-gnome-theme.git
cd gundam-celestial-gnome-theme
./install.sh
```

---

## CLI Flags Reference

| Flag                | Mode / Action         | Description                                                                                                  |
| :------------------ | :-------------------- | :----------------------------------------------------------------------------------------------------------- |
| _(None)_            | **Turnkey Setup**     | Full pipeline: ZRAM, packages, typography, cursor, CSS, extension hardening, preset, and relog prompt.       |
| `--doctor`          | **System Diagnostic** | Audits ZRAM engine (`zramctl`), wallpaper URI accessibility, local icon/cursor assets, and extension status. |
| `--dry-run`         | **Safe Simulation**   | Verifies network, assets, and previews schema changes non-destructively without disk writes.                 |
| `--restore`         | **Instant Rollback**  | Discovers the latest timestamped `dconf` backup snapshot in `~/.config/` and reloads it immediately.         |
| `-u`, `--user-only` | **User-Space Only**   | Applies user configurations, cursors, CSS injection, and presets without root/package prompts.               |
| `-c`, `--check`     | **Asset Audit**       | Runs the non-destructive audit and preview suite (alias for `--dry-run`).                                    |
| `-h`, `--help`      | **Help Screen**       | Displays command usage and available execution options.                                                      |

---

## Diagnostic Tooling (`--doctor`)

Run the built-in diagnostic doctor to verify system health and configuration status at any time:

```bash
./install.sh --doctor
```

The diagnostic doctor systematically audits:

1. **Memory Engine**: Verifies active ZRAM device (`/dev/zram0`), swap mount, and confirms high-speed `zstd` compression.
2. **Wallpaper URI Validity**: Tests dark, light, and lockscreen wallpaper URIs against physical filesystem assets.
3. **Icons & Cursors**: Verifies existence of `MacOS-Tahoe` (24px) and `Nordzy-dark` in `~/.local/share/icons/` (or `/usr/share/icons/`).
4. **Extension Hardening**: Confirms `disable-user-extensions = false` and registers core extensions (`dash-to-dock`, `logomenu`, `Resource_Monitor`).
5. **Libadwaita Window Controls**: Verifies active CSS stylesheet at `~/.config/gtk-4.0/gtk.css`.

---

## Verification & Health Check

After installation, verify the active environment:

### 1. Verify ZRAM Activation

```bash
zramctl
```

_Expected output:_

```text
NAME       ALGORITHM DISKSIZE  DATA COMPR TOTAL STREAMS MOUNTPOINT
/dev/zram0 zstd          7.5G    0B    0B    0B       X [SWAP]
```

### 2. Verify GNOME Settings & Aesthetics

```bash
# Verify window button layout (left-aligned)
gsettings get org.gnome.desktop.wm.preferences button-layout
# Returns: 'close,minimize,maximize:'

# Verify font typography
gsettings get org.gnome.desktop.interface font-name
# Returns: 'JetBrains Mono 10'

# Verify cursor theme & size
gsettings get org.gnome.desktop.interface cursor-theme
# Returns: 'MacOS-Tahoe'
gsettings get org.gnome.desktop.interface cursor-size
# Returns: 24

# Verify dock opacity & fixed transparency mode
gsettings get org.gnome.shell.extensions.dash-to-dock transparency-mode
# Returns: 'FIXED'
gsettings get org.gnome.shell.extensions.dash-to-dock background-opacity
# Returns: 0.45

# Verify dock overview collision prevention
dconf read /org/gnome/shell/extensions/dash-to-dock/hide-in-overview
# Returns: true

# Verify search bar disabled in overview
gsettings get org.gnome.shell.extensions.just-perfection search
# Returns: false

# Verify GTK theme
gsettings get org.gnome.desktop.interface gtk-theme
# Returns: 'WhiteSur-Dark'
```

---

## Wayland Session Notice

Because modern GNOME runs on native **Wayland** sessions without X11 server restarts (`Alt+F2` + `r` is unsupported on Wayland), newly installed Shell extensions, cursor schemes, Firefox userChrome, and Libadwaita styling require an active session relog:

```bash
loginctl terminate-user "$USER"
```

At the completion of `./install.sh`, an interactive prompt asks if you would like to log out immediately:

```text
[✔] Setup completed! A session reload is required to apply all visual changes.
Log out now to apply changes? (y/N):
```

Answering `y` performs an instant session logout via `loginctl terminate-user "$USER"`, instantly activating all visual elements, extensions, and styling upon next login.

---

## Troubleshooting Guide

### 1. Lockscreen Wallpaper Permissions & Black Screen Fix
If the lockscreen or screensaver shows a black screen or reverts to standard defaults, ensure the target image is located in the persistent user backgrounds directory with `644` read permissions:

```bash
# Verify wallpaper file permissions (must be 644)
ls -l ~/.local/share/backgrounds/gundam-lock.jpg

# Fix permissions if necessary
chmod 644 ~/.local/share/backgrounds/gundam-*.jpg

# Re-apply explicit gsettings keys
gsettings set org.gnome.desktop.screensaver picture-uri "file://${HOME}/.local/share/backgrounds/gundam-lock.jpg"
gsettings set org.gnome.desktop.screensaver picture-uri-dark "file://${HOME}/.local/share/backgrounds/gundam-lock.jpg"
gsettings set org.gnome.desktop.screensaver picture-options 'zoom'
```

### 2. Firefox userChrome Styling Verification
If Firefox window controls or GN particle green highlights do not appear after installation:
1. Open `about:config` in Firefox and confirm `toolkit.legacyUserProfileCustomizations.stylesheets` is set to `true`.
2. Confirm `browser.tabs.drawInTitlebar` is set to `true`.
3. Verify `userChrome.css` is present under `~/.mozilla/firefox/<profile>/chrome/userChrome.css`.
4. Run `./install.sh --user-only` to re-deploy browser styling.

### 3. Desktop State Recovery & Snapshots
If desktop configurations require rollback:
```bash
# Automatic rollback to latest snapshot
./install.sh --restore

# Manual restoration from a specific timestamped snapshot
ls -lt ~/.config/dconf-backup-*.dconf
dconf load / < ~/.config/dconf-backup-YYYYMMDD_HHMMSS.dconf
```

---

## Author & Maintainer

**parikesitad-pm**  
Principal Linux System Architect & DevOps Engineer  
MIT License &copy; 2026

Wallpapers and logos are properties of their respective creators (Sotsu / Sunrise / Bandai Namco).
