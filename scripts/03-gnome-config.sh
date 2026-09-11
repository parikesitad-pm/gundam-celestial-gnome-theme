#!/usr/bin/env bash
# ==============================================================================
# Gundam Celestial GNOME Theme - Module 03: GNOME Shell & UI Configuration
# Target: GNOME 50.4 on Wayland
# Declarative gsettings: macOS window controls, dynamic wallpapers, Nordzy icons,
# floating autohide dock, Celestial Being Logo Menu, lean CPU/RAM Resource Monitor
# ==============================================================================

set -euo pipefail

# Visual formatting
BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[GNOME INFO]${NC} $*"; }
log_ok()   { echo -e "${GREEN}[GNOME OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[GNOME WARN]${NC} $*"; }
log_err()  { echo -e "${RED}[GNOME ERROR]${NC} $*" >&2; }

echo -e "${BOLD}${CYAN}==> [03/03] Applying Declarative GNOME Shell Configuration${NC}"

# Resolve repository root directory dynamically
REPO_DIR="${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
log_info "Repository root resolved to: ${REPO_DIR}"

# Helper function to apply gsettings safely
set_gsetting() {
    local schema="$1"
    local key="$2"
    local val="$3"

    # Verify schema exists in gsettings
    if ! gsettings list-schemas | grep -qx "${schema}"; then
        log_warn "Schema '${schema}' not installed yet; skipping '${key}'."
        return 0
    fi

    # Set value
    if gsettings set "${schema}" "${key}" "${val}" 2>/dev/null; then
        log_ok "${schema} -> ${key} = ${val}"
    else
        log_warn "Failed to set ${schema} ${key} to ${val}"
    fi
}

# Helper function to enable gnome extension
enable_extension() {
    local uuid="$1"
    if command -v gnome-extensions >/dev/null 2>&1; then
        if gnome-extensions list | grep -qx "${uuid}"; then
            gnome-extensions enable "${uuid}" 2>/dev/null || true
            log_ok "Extension enabled: ${uuid}"
        else
            log_warn "Extension '${uuid}' not found in installed list. It may activate after shell reload."
        fi
    fi
}

# ------------------------------------------------------------------------------
# 1. Window & UI Behavior
# ------------------------------------------------------------------------------
log_info "Configuring Window Controls & Dynamic Wallpapers..."

# macOS-style window controls placed on the left: close,minimize,maximize:
set_gsetting "org.gnome.desktop.wm.preferences" "button-layout" "'close,minimize,maximize:'"

# Default color scheme: prefer-dark
set_gsetting "org.gnome.desktop.interface" "color-scheme" "'prefer-dark'"

# Dynamic Wallpapers
DARK_WP="${REPO_DIR}/assets/img/gundam-dark.jpg"
LIGHT_WP="${REPO_DIR}/assets/img/gundam-light.jpg"
LOCK_WP="${REPO_DIR}/assets/img/gundam-lock.jpg"

if [[ -f "${DARK_WP}" ]]; then
    set_gsetting "org.gnome.desktop.background" "picture-uri-dark" "'file://${DARK_WP}'"
else
    log_warn "Dark wallpaper not found at: ${DARK_WP}"
fi

if [[ -f "${LIGHT_WP}" ]]; then
    set_gsetting "org.gnome.desktop.background" "picture-uri" "'file://${LIGHT_WP}'"
else
    log_warn "Light wallpaper not found at: ${LIGHT_WP}"
fi

if [[ -f "${LOCK_WP}" ]]; then
    set_gsetting "org.gnome.desktop.screensaver" "picture-uri" "'file://${LOCK_WP}'"
else
    log_warn "Lockscreen wallpaper not found at: ${LOCK_WP}"
fi

# ------------------------------------------------------------------------------
# 2. Icons & Dock (Dash to Dock)
# ------------------------------------------------------------------------------
log_info "Configuring Icon Theme & Dash to Dock..."

# Icon Theme: Nordzy-dark (pure SVG vector, 0MB RAM footprint)
set_gsetting "org.gnome.desktop.interface" "icon-theme" "'Nordzy-dark'"

# Dock (Dash to Dock): Bottom-centered, floating, autohide, 48px icons, isolate workspaces
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "dock-position" "'BOTTOM'"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "extend-height" "false"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "dock-fixed" "false"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "autohide" "true"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "intellihide" "true"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "dash-max-icon-size" "48"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "isolate-workspaces" "true"

# ------------------------------------------------------------------------------
# 3. Top Bar & Logo Menu Optimization
# ------------------------------------------------------------------------------
log_info "Configuring Logo Menu Extension with Celestial Being Logo..."

CB_LOGO="${REPO_DIR}/assets/img/logo/cb.png"

if [[ -f "${CB_LOGO}" ]]; then
    set_gsetting "org.gnome.shell.extensions.logo-menu" "use-custom-icon" "true"
    set_gsetting "org.gnome.shell.extensions.logo-menu" "custom-icon-path" "'${CB_LOGO}'"
    set_gsetting "org.gnome.shell.extensions.logo-menu" "symbolic-icon" "false"
    set_gsetting "org.gnome.shell.extensions.logo-menu" "menu-button-icon-size" "22"
    set_gsetting "org.gnome.shell.extensions.logo-menu" "show-activities-button" "false"
    set_gsetting "org.gnome.shell.extensions.logo-menu" "show-power-options" "true"
    set_gsetting "org.gnome.shell.extensions.logo-menu" "show-lockscreen" "true"
else
    log_warn "Celestial Being logo not found at: ${CB_LOGO}"
fi

# ------------------------------------------------------------------------------
# 4. Resource Monitoring Optimization (CPU & RAM Only, 3000ms Refresh)
# ------------------------------------------------------------------------------
log_info "Configuring Resource Monitor (Strict CPU & RAM polling at 3000ms)..."

# Refresh interval: 3 seconds (3000ms)
set_gsetting "org.gnome.shell.extensions.resource-monitor" "refreshtime" "3"

# Position: center panel box (adjacent to the center clock)
set_gsetting "org.gnome.shell.extensions.resource-monitor" "extensionposition" "'center'"

# Enable strictly CPU and RAM
set_gsetting "org.gnome.shell.extensions.resource-monitor" "cpustatus" "true"
set_gsetting "org.gnome.shell.extensions.resource-monitor" "ramstatus" "true"

# Disable all background bloat: GPU, disk, network, temperature, load averages
set_gsetting "org.gnome.shell.extensions.resource-monitor" "swapstatus" "false"
set_gsetting "org.gnome.shell.extensions.resource-monitor" "gpustatus" "false"
set_gsetting "org.gnome.shell.extensions.resource-monitor" "thermalgputemperaturestatus" "false"
set_gsetting "org.gnome.shell.extensions.resource-monitor" "thermalcputemperaturestatus" "false"
set_gsetting "org.gnome.shell.extensions.resource-monitor" "cpufrequencystatus" "false"
set_gsetting "org.gnome.shell.extensions.resource-monitor" "cpuloadaveragestatus" "false"
set_gsetting "org.gnome.shell.extensions.resource-monitor" "diskstatsstatus" "false"
set_gsetting "org.gnome.shell.extensions.resource-monitor" "diskspacestatus" "false"
set_gsetting "org.gnome.shell.extensions.resource-monitor" "netethstatus" "false"
set_gsetting "org.gnome.shell.extensions.resource-monitor" "netwlanstatus" "false"

# ------------------------------------------------------------------------------
# 5. Enable Extensions
# ------------------------------------------------------------------------------
log_info "Enabling GNOME extensions..."
enable_extension "dash-to-dock@micxgx.gmail.com"
enable_extension "logomenu@aryan_k"
enable_extension "Resource_Monitor@Ory0n"

log_ok "GNOME Shell configuration applied successfully."
