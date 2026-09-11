# Gundam Celestial GNOME Theme

[![Manjaro Linux](https://img.shields.io/badge/Manjaro-26.1.2%20Bian--May-35bf5c?logo=manjaro&logoColor=white)](https://manjaro.org)
[![GNOME Shell](<https://img.shields.io/badge/GNOME-50.4%20(Wayland)-4a86cf?logo=gnome&logoColor=white>)](https://www.gnome.org)
[![Memory Strategy](<https://img.shields.io/badge/ZRAM-zstd%20(RAM%20size)-orange?logo=linux&logoColor=white>)](https://github.com/systemd/zram-generator)
[![Architecture](https://img.shields.io/badge/Daemons-Zero%20Background%20Bloat-brightgreen)](#memory-and-performance-strategy)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

An automated, modular, and declarative dotfiles setup suite for Manjaro Linux (GNOME Shell 50.4 on Wayland), tailored for high-performance developer workstations constrained to 8GB physical RAM.

Inspired by **Mobile Suit Gundam 00: Celestial Being**, this profile blends macOS-style desktop aesthetics with an ultra-lean Linux architecture: zero background runtime daemons, native Wayland compliance, hardware-efficient dynamic wallpapers, pure SVG vector icon rendering, and proactive zstd RAM compression.

---

## Visual & Functional Specifications

| Component             | Target Configuration                                                               | Technical Implementation                                                 |
| :-------------------- | :--------------------------------------------------------------------------------- | :----------------------------------------------------------------------- |
| **Window Controls**   | Left-aligned macOS buttons (`close,minimize,maximize:`)                            | `org.gnome.desktop.wm.preferences button-layout`                         |
| **Color Scheme**      | Prefer Dark                                                                        | `org.gnome.desktop.interface color-scheme 'prefer-dark'`                 |
| **Dynamic Wallpaper** | Gundam Celestial Being Dark & Light wallpapers                                     | Native `org.gnome.desktop.background picture-uri-dark` & `picture-uri`   |
| **Lockscreen**        | Gundam Celestial Being Lockscreen                                                  | `org.gnome.desktop.screensaver picture-uri`                              |
| **Icon Theme**        | `Nordzy-dark` (Pure SVG vector, 0MB RAM footprint)                                 | `org.gnome.desktop.interface icon-theme 'Nordzy-dark'`                   |
| **Dock**              | Dash to Dock: Bottom-centered, floating, autohide, 48px icons, isolated workspaces | `org.gnome.shell.extensions.dash-to-dock`                                |
| **Top-Left Menu**     | Celestial Being logo (`cb.png`) replacing Activities button with macOS dropdown    | `org.gnome.shell.extensions.logo-menu` (`logomenu@aryan_k`)              |
| **Resource Monitor**  | CPU and RAM usage strictly displayed to the right of center clock at 3000ms        | `org.gnome.shell.extensions.resource-monitor` (`Resource_Monitor@Ory0n`) |
| **Memory Strategy**   | ZRAM (`zstd`, `zram-size = ram`) + sysctl paging tuning                            | `zram-generator` + `/etc/sysctl.d/99-zram.conf`                          |

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
├── install.sh                  # Main orchestrator & entrypoint
├── scripts/
│   ├── 01-zram.sh             # ZRAM generator & sysctl memory optimizations
│   ├── 02-packages.sh         # Dependency resolution (Pacman + AUR/yay)
│   └── 03-gnome-config.sh     # Declarative gsettings & GNOME extensions setup
├── assets/
│   └── img/
│       ├── gundam-dark.jpg    # Dynamic dark wallpaper (1672x941)
│       ├── gundam-light.jpg   # Dynamic light wallpaper (1670x941)
│       ├── gundam-lock.jpg    # Lockscreen wallpaper (1672x941)
│       └── logo/
│           └── cb.png         # Celestial Being transparent PNG logo
└── README.md                   # Documentation & specifications
```

---

## Requirements

- **Operating System**: Manjaro Linux 26.1.2 (Bian-May) or Arch Linux.
- **Desktop Environment**: GNOME Shell 50.4 on Wayland.
- **Privileges**: User account with `sudo` permissions (for ZRAM and pacman).
- **AUR Helper**: `yay` (recommended) or `paru`.

---

## Quickstart Installation

Clone the repository and run the idempotent installation script:

```bash
git clone https://github.com/<your-username>/gundam-celestial-gnome-theme.git
cd gundam-celestial-gnome-theme
./install.sh
```

The script will:

1. Dynamically resolve the absolute repository path (`REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`) ensuring valid `file://` URIs for all assets regardless of clone location.
2. Verify asset integrity under `assets/img/` with fallback warnings.
3. Configure and activate ZRAM (`zstd`, `zram-size = ram`) and reload systemd ZRAM services.
4. Idempotently install all missing official and AUR dependencies.
5. Apply all declarative `gsettings` and enable the extensions.

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

### 2. Verify GNOME Settings

```bash
# Verify window button layout
gsettings get org.gnome.desktop.wm.preferences button-layout
# Returns: 'close,minimize,maximize:'

# Verify dark wallpaper URI
gsettings get org.gnome.desktop.background picture-uri-dark

# Verify Celestial Being custom logo in Logo Menu
gsettings get org.gnome.shell.extensions.logo-menu custom-icon-path
```

### 3. Wayland Session Refresh

On Wayland sessions, newly installed extensions are registered cleanly after logging out and logging back in:

```bash
gnome-session-quit --logout
```

---

## License

Released under the [MIT License](LICENSE).
Wallpapers and logos are properties of their respective creators (Sotsu / Sunrise / Bandai Namco).
