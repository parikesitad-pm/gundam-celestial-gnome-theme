#!/usr/bin/env bash
# ==============================================================================
# Project:     gundam-celestial-gnome-theme
# Module:      03 - GNOME Shell & UI Configuration (scripts/03-gnome-config.sh)
# Target:      Manjaro 26.1.2 (Bian-May) | GNOME Shell 50.4 (Wayland)
# Author:      parikesitad-pm
# License:     MIT License (c) 2026
# Declarative gsettings: macOS window controls, dynamic wallpapers, Nordzy icons,
# floating autohide dock (hide-in-overview), Celestial Being Logo Menu, lean CPU/RAM
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

# Persistent Dynamic Wallpapers & Lockscreen
DARK_WP="${REPO_DIR}/assets/img/gundam-dark.jpg"
LIGHT_WP="${REPO_DIR}/assets/img/gundam-light.jpg"
LOCK_WP="${REPO_DIR}/assets/img/gundam-lock.jpg"

BG_DIR="${HOME}/.local/share/backgrounds"
mkdir -p "${BG_DIR}"

if [[ -f "${DARK_WP}" ]]; then
    cp -f "${DARK_WP}" "${BG_DIR}/gundam-dark.jpg"
    chmod 644 "${BG_DIR}/gundam-dark.jpg"
    set_gsetting "org.gnome.desktop.background" "picture-uri-dark" "'file://${BG_DIR}/gundam-dark.jpg'"
    set_gsetting "org.gnome.desktop.background" "picture-options" "'zoom'"
else
    log_warn "Dark wallpaper not found at: ${DARK_WP}"
fi

if [[ -f "${LIGHT_WP}" ]]; then
    cp -f "${LIGHT_WP}" "${BG_DIR}/gundam-light.jpg"
    chmod 644 "${BG_DIR}/gundam-light.jpg"
    set_gsetting "org.gnome.desktop.background" "picture-uri" "'file://${BG_DIR}/gundam-light.jpg'"
    set_gsetting "org.gnome.desktop.background" "picture-options" "'zoom'"
else
    log_warn "Light wallpaper not found at: ${LIGHT_WP}"
fi

if [[ -f "${LOCK_WP}" ]]; then
    cp -f "${LOCK_WP}" "${BG_DIR}/gundam-lock.jpg"
    chmod 644 "${BG_DIR}/gundam-lock.jpg"
    set_gsetting "org.gnome.desktop.screensaver" "picture-uri" "'file://${BG_DIR}/gundam-lock.jpg'"
    set_gsetting "org.gnome.desktop.screensaver" "picture-uri-dark" "'file://${BG_DIR}/gundam-lock.jpg'"
    set_gsetting "org.gnome.desktop.screensaver" "picture-options" "'zoom'"
else
    log_warn "Lockscreen wallpaper not found at: ${LOCK_WP}"
fi

# ------------------------------------------------------------------------------
# 2. Typography & Cursors (JetBrains Mono & MacOS Tahoe)
# ------------------------------------------------------------------------------
log_info "Applying JetBrains Mono Typography..."
set_gsetting "org.gnome.desktop.interface" "font-name" "'JetBrains Mono 10'"
set_gsetting "org.gnome.desktop.interface" "monospace-font-name" "'JetBrains Mono 10'"
set_gsetting "org.gnome.desktop.interface" "document-font-name" "'JetBrains Mono 10'"

log_info "Fetching & Registering MacOS Tahoe Cursor (24px)..."
CURSOR_DIR="${HOME}/.local/share/icons/MacOS-Tahoe"
if [[ ! -d "${CURSOR_DIR}/cursors" ]]; then
    mkdir -p "${HOME}/.local/share/icons"
    TMP_ZIP="/tmp/MacOS-Tahoe-Cursor.zip"
    TMP_EXTRACT="/tmp/MacOS-Tahoe-Extract"
    rm -rf "${TMP_ZIP}" "${TMP_EXTRACT}"
    if curl -sL --fail "https://github.com/witt-bit/MacOS-Tahoe-Cursor/releases/download/1.2/MacOS-Tahoe-Cursor.zip" -o "${TMP_ZIP}"; then
        unzip -q "${TMP_ZIP}" -d "${TMP_EXTRACT}"
        if [[ -d "${TMP_EXTRACT}/MacOS-Tahoe-Cursor/MacOS-Tahoe-Cursor" ]]; then
            mkdir -p "${CURSOR_DIR}"
            cp -r "${TMP_EXTRACT}/MacOS-Tahoe-Cursor/MacOS-Tahoe-Cursor/"* "${CURSOR_DIR}/"
            log_ok "MacOS Tahoe cursor deployed to ${CURSOR_DIR}."
        fi
        rm -rf "${TMP_ZIP}" "${TMP_EXTRACT}"
    else
        log_warn "Failed to download MacOS Tahoe cursor zip. Fallback to system cursor."
    fi
fi
set_gsetting "org.gnome.desktop.interface" "cursor-theme" "'MacOS-Tahoe'"
set_gsetting "org.gnome.desktop.interface" "cursor-size" "24"

# ------------------------------------------------------------------------------
# 3. Icons & Dock (Dash to Dock)
# ------------------------------------------------------------------------------
log_info "Configuring Icon Theme & Dash to Dock..."

# Ensure Nordzy-dark icon theme exists in ~/.local/share/icons if not installed system-wide
NORDZY_USER_DIR="${HOME}/.local/share/icons/Nordzy-dark"
if [[ ! -d "${NORDZY_USER_DIR}" && ! -d "/usr/share/icons/Nordzy-dark" ]]; then
    mkdir -p "${HOME}/.local/share/icons"
    log_info "Fetching & Extracting Nordzy-dark vector icons..."
    TMP_NORDZY_TAR="/tmp/Nordzy-dark.tar.gz"
    rm -f "${TMP_NORDZY_TAR}"
    if curl -sL --fail --connect-timeout 6 "https://github.com/MolassesLover/Nordzy-icon/releases/download/1.8.7/Nordzy-dark.tar.gz" -o "${TMP_NORDZY_TAR}"; then
        tar -xzf "${TMP_NORDZY_TAR}" -C "${HOME}/.local/share/icons/"
        rm -f "${TMP_NORDZY_TAR}"
        log_ok "Nordzy-dark icon theme deployed to ${NORDZY_USER_DIR}."
    else
        log_warn "Failed to download Nordzy-dark icons. Fallback to system icons."
    fi
fi

# Icon & GTK Themes: Nordzy-dark (SVG vector) & WhiteSur-Dark (macOS aesthetics)
set_gsetting "org.gnome.desktop.interface" "icon-theme" "'Nordzy-dark'"
set_gsetting "org.gnome.desktop.interface" "gtk-theme" "'WhiteSur-Dark'"

# Dock (Dash to Dock): Bottom-centered, floating, autohide, 48px icons, isolate workspaces
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "dock-position" "'BOTTOM'"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "extend-height" "false"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "dock-fixed" "false"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "autohide" "true"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "intellihide" "true"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "dash-max-icon-size" "48"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "isolate-workspaces" "true"

# Flat RGBA transparency (Zero-Blur Policy - 0% compute/Gaussian blur overhead)
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "transparency-mode" "'FIXED'"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "background-opacity" "0.45"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "custom-background-color" "false"

# Window controls: click-to-minimize and running indicators
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "click-action" "'minimize-or-previews'"
set_gsetting "org.gnome.shell.extensions.dash-to-dock" "show-running" "true"

# Dock collision fix: hide dock completely in GNOME Shell overview (Super key)
dconf write /org/gnome/shell/extensions/dash-to-dock/hide-in-overview true
log_ok "org.gnome.shell.extensions.dash-to-dock -> hide-in-overview = true"

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
# 4. macOS Traffic Lights Theming (GTK3 & GTK4/Libadwaita)
# ------------------------------------------------------------------------------
log_info "Configuring macOS Traffic Lights Theming (GTK3 & GTK4/Libadwaita)..."

GTK4_CONFIG_DIR="${HOME}/.config/gtk-4.0"
GTK3_CONFIG_DIR="${HOME}/.config/gtk-3.0"
mkdir -p "${GTK4_CONFIG_DIR}" "${GTK3_CONFIG_DIR}"

# Check for installed WhiteSur-Dark theme assets
WHITESUR_PATH=""
if [[ -d "/usr/share/themes/WhiteSur-Dark/gtk-4.0" ]]; then
    WHITESUR_PATH="/usr/share/themes/WhiteSur-Dark/gtk-4.0"
elif [[ -d "${HOME}/.themes/WhiteSur-Dark/gtk-4.0" ]]; then
    WHITESUR_PATH="${HOME}/.themes/WhiteSur-Dark/gtk-4.0"
fi

if [[ -n "${WHITESUR_PATH}" ]]; then
    log_info "Found WhiteSur theme assets at: ${WHITESUR_PATH}"
    # Symlink assets directories if not already linked
    for asset_dir in assets windows-assets; do
        if [[ -d "${WHITESUR_PATH}/${asset_dir}" && ! -e "${GTK4_CONFIG_DIR}/${asset_dir}" ]]; then
            ln -sf "${WHITESUR_PATH}/${asset_dir}" "${GTK4_CONFIG_DIR}/${asset_dir}"
        fi
    done
fi

# Generate standalone authentic macOS Traffic Lights CSS (red, yellow, green circular buttons)
TRAFFIC_LIGHTS_CSS=$(cat <<'EOF'
/* ==========================================================================
   Gundam Celestial - macOS Window Controls (Traffic Lights)
   System-Wide Support for GTK4, Libadwaita, and GTK3
   ========================================================================== */
windowcontrols {
    padding: 0 4px;
}

windowcontrols button,
headerbar windowcontrols button {
    min-width: 13px !important;
    min-height: 13px !important;
    max-width: 13px !important;
    max-height: 13px !important;
    padding: 0 !important;
    margin: 0 4px !important;
    border-radius: 9999px !important;
    border: 1px solid rgba(0, 0, 0, 0.35) !important;
    background-size: 7px 7px !important;
    background-position: center !important;
    background-repeat: no-repeat !important;
    color: transparent !important;
    box-shadow: none !important;
    -gtk-icon-size: 0px !important;
    transition: all 120ms ease;
}

/* Red (Close) */
windowcontrols button.close,
headerbar windowcontrols button.close {
    background-color: #ff5f56 !important;
    border-color: #e0443e !important;
}

windowcontrols button.close:hover,
headerbar windowcontrols button.close:hover {
    background-color: #ff3b30 !important;
    background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="7" height="7" viewBox="0 0 7 7"><path fill="none" stroke="%234c0000" stroke-width="1.2" stroke-linecap="round" d="M1 1l5 5M6 1L1 6"/></svg>') !important;
}

/* Yellow (Minimize) */
windowcontrols button.minimize,
headerbar windowcontrols button.minimize {
    background-color: #ffbd2e !important;
    border-color: #dea123 !important;
}

windowcontrols button.minimize:hover,
headerbar windowcontrols button.minimize:hover {
    background-color: #ff9500 !important;
    background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="7" height="7" viewBox="0 0 7 7"><path fill="none" stroke="%235a3900" stroke-width="1.2" stroke-linecap="round" d="M0.5 3.5h6"/></svg>') !important;
}

/* Green (Maximize) */
windowcontrols button.maximize,
headerbar windowcontrols button.maximize {
    background-color: #27c93f !important;
    border-color: #1aab29 !important;
}

windowcontrols button.maximize:hover,
headerbar windowcontrols button.maximize:hover {
    background-color: #34c759 !important;
    background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="7" height="7" viewBox="0 0 7 7"><path fill="none" stroke="%230b4200" stroke-width="1.1" stroke-linecap="round" d="M1 2.5l2.5-2 2.5 2M1 4.5l2.5 2 2.5-2"/></svg>') !important;
}

/* Inactive Window / Backdrop State */
windowcontrols button:backdrop,
headerbar windowcontrols button:backdrop {
    background-color: rgba(255, 255, 255, 0.18) !important;
    border-color: rgba(0, 0, 0, 0.25) !important;
    background-image: none !important;
    opacity: 0.65 !important;
}
EOF
)

# Libadwaita CSS Collision Guard: backup pre-existing gtk.css to prevent broken rendering
if [[ -f "${GTK4_CONFIG_DIR}/gtk.css" ]]; then
    local_gtk_backup="${GTK4_CONFIG_DIR}/gtk.css.bak.$(date +%s)"
    mv "${GTK4_CONFIG_DIR}/gtk.css" "${local_gtk_backup}"
    log_info "Pre-existing GTK4 CSS backed up to: $(basename "${local_gtk_backup}")"
fi
if [[ -f "${GTK4_CONFIG_DIR}/gtk-dark.css" ]]; then
    local_gtk_dark_backup="${GTK4_CONFIG_DIR}/gtk-dark.css.bak.$(date +%s)"
    mv "${GTK4_CONFIG_DIR}/gtk-dark.css" "${local_gtk_dark_backup}"
fi

# Inject into GTK4/Libadwaita configurations
echo "${TRAFFIC_LIGHTS_CSS}" > "${GTK4_CONFIG_DIR}/gtk.css"
echo "${TRAFFIC_LIGHTS_CSS}" > "${GTK4_CONFIG_DIR}/gtk-dark.css"

# Inject into GTK3 configuration
echo "${TRAFFIC_LIGHTS_CSS}" > "${GTK3_CONFIG_DIR}/gtk.css"
log_ok "macOS traffic lights CSS successfully injected into GTK4 and GTK3 configs."

# ------------------------------------------------------------------------------
# 5. Flat RGBA Top Bar & Overview Styling (Zero-Blur Policy)
# ------------------------------------------------------------------------------
log_info "Configuring Flat RGBA Top Bar & Overview (Zero-Blur Policy)..."

# Top Bar Flat RGBA stylesheet (semi-transparent alpha without Gaussian blur compute overhead)
TOPBAR_CSS=$(cat <<'EOF'
/* ==========================================================================
   Gundam Celestial - Flat RGBA Alpha Aesthetics (Zero-Blur Policy)
   ========================================================================== */
#panel {
    background-color: rgba(18, 22, 28, 0.45) !important;
    box-shadow: none !important;
    border-bottom: 1px solid rgba(255, 255, 255, 0.08) !important;
    transition: background-color 200ms ease;
}

#panel.unlock-screen,
#panel.login-screen,
#panel:overview {
    background-color: transparent !important;
    border-bottom: none !important;
}

/* Clutter-Free Overview - Collapse Search Box */
.search-entry,
#searchEntry {
    height: 0px !important;
    min-height: 0px !important;
    max-height: 0px !important;
    padding: 0px !important;
    margin: 0px !important;
    border: none !important;
    opacity: 0 !important;
}
EOF
)

# Deploy to User Themes directory
USER_THEMES_DIR="${HOME}/.local/share/themes/Gundam-Celestial/gnome-shell"
mkdir -p "${USER_THEMES_DIR}"
echo "${TOPBAR_CSS}" > "${USER_THEMES_DIR}/gnome-shell.css"

# Also deploy to ~/.config/gnome-shell/gnome-shell.css
GNOME_SHELL_CONFIG_DIR="${HOME}/.config/gnome-shell"
mkdir -p "${GNOME_SHELL_CONFIG_DIR}"
echo "${TOPBAR_CSS}" > "${GNOME_SHELL_CONFIG_DIR}/gnome-shell.css"

# Disable native search bar via Just Perfection extension
set_gsetting "org.gnome.shell.extensions.just-perfection" "search" "false"

# Configure user-theme extension to activate Gundam-Celestial shell stylesheet
set_gsetting "org.gnome.shell.extensions.user-theme" "name" "'Gundam-Celestial'"
log_ok "Flat RGBA top bar stylesheet active (Gundam-Celestial) with zero blur."

# ------------------------------------------------------------------------------
# 7. Shortcuts: Ulauncher Spotlight Integration (Ctrl + Space)
# ------------------------------------------------------------------------------
log_info "Configuring Ulauncher Spotlight Shortcut (Ctrl + Space)..."
if command -v ulauncher >/dev/null 2>&1 || [[ -d "${HOME}/.config/ulauncher" ]]; then
    mkdir -p "${HOME}/.config/ulauncher"
    ULAUNCHER_SETTINGS="${HOME}/.config/ulauncher/settings.json"
    if [[ -f "${ULAUNCHER_SETTINGS}" ]]; then
        if grep -q '"hotkey-show-app"' "${ULAUNCHER_SETTINGS}"; then
            sed -i 's/"hotkey-show-app": "[^"]*"/"hotkey-show-app": "<Primary>space"/' "${ULAUNCHER_SETTINGS}"
        else
            sed -i '1s/{/{\n    "hotkey-show-app": "<Primary>space",/' "${ULAUNCHER_SETTINGS}"
        fi
    else
        cat <<'EOF' > "${ULAUNCHER_SETTINGS}"
{
    "hotkey-show-app": "<Primary>space"
}
EOF
    fi
    log_ok "Ulauncher settings.json configured with <Primary>space."
fi

# GNOME custom media keybinding for Ulauncher
set_gsetting "org.gnome.settings-daemon.plugins.media-keys" "custom-keybindings" "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Control>space'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'ulauncher-toggle'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'Ulauncher'"
log_ok "GNOME custom shortcut mapped: Ctrl + Space -> ulauncher-toggle."

# ------------------------------------------------------------------------------
# 8. Extension Auto-Activation & Hardening
# ------------------------------------------------------------------------------
log_info "Hardening & Auto-Activating GNOME Extensions..."

# Explicitly disable extension lock
gsettings set org.gnome.shell disable-user-extensions false
log_ok "org.gnome.shell -> disable-user-extensions = false"

CORE_EXTENSION_UUIDS=(
    "dash-to-dock@micxgx.gmail.com"
    "logomenu@aryan_k"
    "Resource_Monitor@Ory0n"
    "user-theme@gnome-shell-extensions.gcampax.github.com"
    "just-perfection-desktop@just-perfection"
)

# Programmatically enable via gnome-extensions CLI
for uuid in "${CORE_EXTENSION_UUIDS[@]}"; do
    enable_extension "${uuid}"
done

# Ensure core extension UUIDs are registered directly in org.gnome.shell enabled-extensions
current_exts="$(gsettings get org.gnome.shell enabled-extensions 2>/dev/null || echo '[]')"
for uuid in "${CORE_EXTENSION_UUIDS[@]}"; do
    if [[ ! "${current_exts}" =~ "${uuid}" ]]; then
        if [[ "${current_exts}" == "@as []" || "${current_exts}" == "[]" ]]; then
            current_exts="['${uuid}']"
        else
            current_exts="${current_exts%]*}, '${uuid}']"
        fi
    fi
done
gsettings set org.gnome.shell enabled-extensions "${current_exts}" 2>/dev/null || true
log_ok "Core extensions registered in org.gnome.shell enabled-extensions."

log_ok "GNOME Shell configuration applied successfully."
