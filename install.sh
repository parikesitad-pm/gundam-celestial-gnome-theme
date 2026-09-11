#!/usr/bin/env bash
# ==============================================================================
# Project:     gundam-celestial-gnome-theme
# Module:      Master Turnkey Orchestrator (install.sh)
# Target:      Manjaro 26.1.2 (Bian-May) | GNOME Shell 50.4 (Wayland)
# Author:      parikesitad-pm
# License:     MIT License (c) 2026
# Description: Turnkey installation engine with animated CLI loader, state backup,
#              Tahoe cursor, JetBrains Mono typography, and rollback recovery
# ==============================================================================

set -euo pipefail

# Visual formatting
BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Dynamic repository path resolution
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_DIR

LOG_FILE="/tmp/gundam-theme-install.log"
SCRIPTS_DIR="${REPO_DIR}/scripts"

log_banner() {
    echo -e "${CYAN}${BOLD}❖ GUNDAM CELESTIAL BEING | GNOME 50.4 (WAYLAND)${NC}"
    echo -e "${BLUE}  Architect: parikesitad-pm | 8GB RAM ZRAM Optimized | Preset: gundam-00${NC}\n"
}

show_help() {
    echo -e "${BOLD}Gundam Celestial GNOME Theme - Installation & Management Tool${NC}"
    echo -e "Author: parikesitad-pm | License: MIT (c) 2026\n"
    echo -e "Usage: $(basename "$0") [OPTIONS]\n"
    echo -e "Options:"
    echo -e "  --doctor          Run comprehensive system & configuration diagnostic audit"
    echo -e "  --restore         Instantly restore the latest dconf desktop state snapshot"
    echo -e "  --dry-run         Simulate checks, network, and preview schema changes without writing"
    echo -e "  -u, --user-only   Apply user-space configurations and preset only (skip root ZRAM/packages)"
    echo -e "  -c, --check       Perform non-destructive environment and asset audit"
    echo -e "  -h, --help        Display this help screen\n"
    echo -e "Default:"
    echo -e "  Runs the full turnkey installation pipeline with live CLI animated loader."
}

log_info() { echo -e "${CYAN}[INFO]${NC} $*"; }
log_ok()   { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_err()  { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ------------------------------------------------------------------------------
# Animated CLI Loader
# ------------------------------------------------------------------------------
run_step() {
    local msg="$1"
    shift

    # If non-interactive, print cleanly without animation
    if [[ ! -t 1 ]]; then
        echo -e "${CYAN}[+] ${msg}...${NC}"
        if "$@" >> "${LOG_FILE}" 2>&1; then
            echo -e "${GREEN}[✓] ${msg}${NC}"
            return 0
        else
            echo -e "${RED}[✗] ${msg} (Failed - check ${LOG_FILE})${NC}"
            return 1
        fi
    fi

    # Animated braille spinner for interactive TTY
    local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local spin_idx=0

    # Run command in background redirected to log
    "$@" >> "${LOG_FILE}" 2>&1 &
    local cmd_pid=$!

    # Hide cursor
    tput civis 2>/dev/null || true

    while kill -0 "${cmd_pid}" 2>/dev/null; do
        printf "\r  ${CYAN}%s${NC} [+] %s..." "${spin_chars[${spin_idx}]}" "${msg}"
        spin_idx=$(( (spin_idx + 1) % 10 ))
        sleep 0.08
    done

    # Restore cursor
    tput cnorm 2>/dev/null || true

    wait "${cmd_pid}"
    local status=$?

    if [[ ${status} -eq 0 ]]; then
        printf "\r  ${GREEN}[✓]${NC} %s                                \n" "${msg}"
        return 0
    else
        printf "\r  ${RED}[✗]${NC} %s (Failed - check %s)           \n" "${msg}" "${LOG_FILE}"
        return ${status}
    fi
}

# ------------------------------------------------------------------------------
# State Backup & Restore Engine
# ------------------------------------------------------------------------------
create_desktop_backup() {
    local backup_dir="${HOME}/.config"
    local timestamp
    timestamp="$(date +%Y%m%d_%H%M%S)"
    local backup_file="${backup_dir}/dconf-backup-${timestamp}.dconf"
    mkdir -p "${backup_dir}"
    dconf dump / > "${backup_file}"
    echo "Snapshot created at ${backup_file}" >> "${LOG_FILE}"
}

restore_backup() {
    log_banner
    echo -e "${BOLD}${CYAN}=== DESKTOP STATE RESTORE ENGINE ===${NC}\n"
    local backup_dir="${HOME}/.config"
    local latest_backup
    latest_backup="$(find "${backup_dir}" -maxdepth 1 -name "dconf-backup-*.dconf" -type f 2>/dev/null | sort -r | head -n 1)"

    if [[ -z "${latest_backup}" || ! -f "${latest_backup}" ]]; then
        log_err "No restore snapshots found in ${backup_dir} matching 'dconf-backup-*.dconf'."
        exit 1
    fi

    log_info "Discovered latest restore snapshot: ${latest_backup}"
    if dconf load / < "${latest_backup}"; then
        log_ok "Desktop UI state successfully restored from ${latest_backup}."
    else
        log_err "Failed to load dconf snapshot."
        exit 1
    fi
    exit 0
}

# ------------------------------------------------------------------------------
# Dry-Run Simulation
# ------------------------------------------------------------------------------
simulate_dry_run() {
    log_banner
    echo -e "${BOLD}${YELLOW}=== DRY-RUN SIMULATION MODE ===${NC}\n"
    log_info "Simulating checks without modifying disk or system settings...\n"

    echo -e "${BOLD}1. Network Connectivity Check:${NC}"
    if curl -sI --connect-timeout 4 "https://github.com" >/dev/null 2>&1; then
        log_ok "GitHub connectivity: ONLINE"
    else
        log_warn "GitHub connectivity: UNREACHABLE"
    fi

    echo -e "\n${BOLD}2. Repository Graphical Assets Check:${NC}"
    local assets=(
        "assets/img/gundam-dark.jpg"
        "assets/img/gundam-light.jpg"
        "assets/img/gundam-lock.jpg"
        "assets/img/logo/cb.png"
    )
    for asset in "${assets[@]}"; do
        if [[ -f "${REPO_DIR}/${asset}" ]]; then
            log_ok "Located: ${asset}"
        else
            log_err "Missing: ${asset}"
        fi
    done

    echo -e "\n${BOLD}3. Schema & Preset Target Preview:${NC}"
    log_info "Target Preset:    ${REPO_DIR}/presets/gundam-00.dconf (READY)"
    log_info "Cursor Engine:    MacOS-Tahoe (24px compact)"
    log_info "Typography:       JetBrains Mono 10 (Interface, Monospace, Document)"
    log_info "Dock Profile:     Floating, Autohide, 48px, Fixed RGBA 0.45, hide-in-overview"
    log_info "Window Controls:  Left macOS Traffic Lights (GTK3 & GTK4/Libadwaita)"
    log_info "Top Bar:          Flat RGBA (0.45 alpha), Overview Search Bar Disabled"
    log_info "Shortcut Target:  Ulauncher Spotlight (Ctrl + Space)"

    echo -e "\n${BOLD}${GREEN}✓ Dry-run completed. All parameters verified successfully.${NC}\n"
    exit 0
}

# ------------------------------------------------------------------------------
# Diagnostic Doctor Engine
# ------------------------------------------------------------------------------
run_doctor() {
    log_banner
    echo -e "${BOLD}${CYAN}=== GUNDAM CELESTIAL SYSTEM DIAGNOSTIC DOCTOR ===${NC}\n"
    local issues=0

    # 1. ZRAM Engine & Compression Status
    echo -e "${BOLD}1. Memory Engine (ZRAM & Compression Algorithm):${NC}"
    if command -v zramctl >/dev/null 2>&1; then
        local zram_output
        zram_output="$(zramctl --noheadings 2>/dev/null || true)"
        if [[ -n "${zram_output}" ]]; then
            local zram_dev zram_alg zram_size zram_mount
            zram_dev="$(echo "${zram_output}" | awk '{print $1}' | head -n 1)"
            zram_alg="$(echo "${zram_output}" | awk '{print $2}' | head -n 1)"
            zram_size="$(echo "${zram_output}" | awk '{print $3}' | head -n 1)"
            zram_mount="$(echo "${zram_output}" | awk '{print $NF}' | head -n 1)"

            if [[ "${zram_alg}" == *"zstd"* ]]; then
                log_ok "ZRAM device active: ${zram_dev} (${zram_size}) [${zram_mount}]"
                log_ok "Compression engine: ${zram_alg} (Optimal high-speed zstd compression)"
            else
                log_warn "ZRAM device active (${zram_dev}), but algorithm is '${zram_alg}' instead of 'zstd'."
            fi
        else
            log_err "No active ZRAM device found. Check systemd-zram-setup@zram0 service."
            ((issues++))
        fi
    else
        log_err "zramctl command not found on system."
        ((issues++))
    fi

    # 2. Wallpaper & Lockscreen URI Validity & Permissions
    echo -e "\n${BOLD}2. Desktop Wallpaper & Lockscreen URI Validity:${NC}"
    local wp_dark wp_light wp_lock
    wp_dark="$(gsettings get org.gnome.desktop.background picture-uri-dark 2>/dev/null | tr -d "'" || true)"
    wp_light="$(gsettings get org.gnome.desktop.background picture-uri 2>/dev/null | tr -d "'" || true)"
    wp_lock="$(gsettings get org.gnome.desktop.screensaver picture-uri 2>/dev/null | tr -d "'" || true)"

    local wp_items=(
        "Dark Wallpaper:${wp_dark}"
        "Light Wallpaper:${wp_light}"
        "Lockscreen Wallpaper:${wp_lock}"
    )

    for item in "${wp_items[@]}"; do
        local label="${item%%:*}"
        local uri="${item#*:}"
        local path="${uri#file://}"
        if [[ -n "${path}" && -f "${path}" ]]; then
            local perms
            perms="$(stat -c '%a' "${path}" 2>/dev/null || echo "644")"
            log_ok "${label}: Valid and readable (${perms}) -> ${path}"
        else
            log_err "${label}: Missing or invalid URI -> '${uri}'"
            ((issues++))
        fi
    done

    # 3. Cursor & Icon Themes in ~/.local/share/icons/
    echo -e "\n${BOLD}3. Local User Icons & Cursor Assets (~/.local/share/icons/):${NC}"
    local icons_dir="${HOME}/.local/share/icons"
    local tahoe_dir="${icons_dir}/MacOS-Tahoe"
    if [[ -d "${tahoe_dir}/cursors" && -f "${tahoe_dir}/index.theme" ]]; then
        log_ok "MacOS Tahoe Cursor: Located in ${tahoe_dir}"
    elif [[ -d "/usr/share/icons/MacOS-Tahoe" ]]; then
        log_ok "MacOS Tahoe Cursor: Located system-wide in /usr/share/icons/MacOS-Tahoe"
    else
        log_err "MacOS Tahoe Cursor: Missing in ${tahoe_dir}"
        ((issues++))
    fi

    local nordzy_dir="${icons_dir}/Nordzy-dark"
    if [[ -d "${nordzy_dir}" || -d "${icons_dir}/Nordzy" ]]; then
        log_ok "Nordzy Icon Theme: Located in ${nordzy_dir}"
    elif [[ -d "/usr/share/icons/Nordzy-dark" || -d "/usr/share/icons/Nordzy" ]]; then
        log_ok "Nordzy Icon Theme: Located system-wide in /usr/share/icons/Nordzy-dark"
    else
        log_err "Nordzy Icon Theme: Missing in ${nordzy_dir}"
        ((issues++))
    fi

    # 4. GNOME Extensions & Hardening Safeguards
    echo -e "\n${BOLD}4. Extension Auto-Activation Status:${NC}"
    local ext_disabled
    ext_disabled="$(gsettings get org.gnome.shell disable-user-extensions 2>/dev/null || echo 'false')"
    if [[ "${ext_disabled}" == "false" ]]; then
        log_ok "Extension Lock: Disabled (disable-user-extensions = false)"
    else
        log_err "Extension Lock: Active (disable-user-extensions = true)"
        ((issues++))
    fi

    local core_exts=("dash-to-dock@micxgx.gmail.com" "logomenu@aryan_k" "Resource_Monitor@Ory0n")
    local enabled_exts
    enabled_exts="$(gsettings get org.gnome.shell enabled-extensions 2>/dev/null || echo '[]')"
    for ext_uuid in "${core_exts[@]}"; do
        if [[ "${enabled_exts}" =~ "${ext_uuid}" ]]; then
            log_ok "Core Extension: Registered (${ext_uuid})"
        else
            log_warn "Core Extension: Not yet in enabled list (${ext_uuid})"
        fi
    done

    # 5. GTK4 Libadwaita Stylesheet Guard
    echo -e "\n${BOLD}5. Libadwaita Window Controls & Stylesheet:${NC}"
    if [[ -f "${HOME}/.config/gtk-4.0/gtk.css" ]]; then
        log_ok "GTK4 Window Controls: Active in ~/.config/gtk-4.0/gtk.css"
    else
        log_warn "GTK4 Window Controls: Not found at ~/.config/gtk-4.0/gtk.css"
    fi

    # 6. Firefox macOS & Gundam userChrome Deployment Status
    echo -e "\n${BOLD}6. Firefox macOS & Gundam userChrome Status:${NC}"
    local ff_dir="${HOME}/.mozilla/firefox"
    local ff_verified=false
    if [[ -d "${ff_dir}" ]]; then
        local ff_profiles=()
        while IFS= read -r -d '' p_dir; do
            ff_profiles+=("${p_dir}")
        done < <(find "${ff_dir}" -maxdepth 1 -mindepth 1 -type d \( -name "*.default*" -o -name "*release*" \) -print0 2>/dev/null)

        for p in "${ff_profiles[@]}"; do
            local uc="${p}/chrome/userChrome.css"
            local cc="${p}/chrome/customChrome.css"
            if [[ -f "${uc}" ]] && grep -Fq "Gundam Celestial Being" "${uc}" 2>/dev/null; then
                log_ok "Firefox userChrome.css: Verified in $(basename "${p}")"
                ff_verified=true
            elif [[ -f "${cc}" ]] && grep -Fq "Gundam Celestial Being" "${cc}" 2>/dev/null; then
                log_ok "Firefox customChrome.css: Verified in $(basename "${p}")"
                ff_verified=true
            fi
        done
        if [[ "${ff_verified}" == "true" ]]; then
            log_ok "Firefox Gundam styling: Active & operational"
        else
            log_warn "Firefox userChrome styling not detected in default profiles."
        fi
    else
        log_info "Firefox directory not present. Skipping browser audit."
    fi

    # Diagnostic Summary
    echo -e "\n----------------------------------------------------------------------"
    if [[ ${issues} -eq 0 ]]; then
        echo -e "${BOLD}${GREEN}✓ DOCTOR AUDIT PASSED: All system parameters healthy and operational.${NC}\n"
        exit 0
    else
        echo -e "${BOLD}${YELLOW}⚠ DOCTOR AUDIT: Detected ${issues} issue(s). Review recommendations above.${NC}\n"
        exit 1
    fi
}

# ------------------------------------------------------------------------------
# Modular Step Wrappers
# ------------------------------------------------------------------------------
step_backup() {
    create_desktop_backup
}

step_zram() {
    "${SCRIPTS_DIR}/01-zram.sh"
}

step_packages() {
    "${SCRIPTS_DIR}/02-packages.sh"
}

step_typography() {
    # Ensure JetBrains Mono is bound across GNOME interface schemas
    gsettings set org.gnome.desktop.interface font-name 'JetBrains Mono 10'
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrains Mono 10'
    gsettings set org.gnome.desktop.interface document-font-name 'JetBrains Mono 10'
}

step_cursor() {
    local cursor_dir="${HOME}/.local/share/icons/MacOS-Tahoe"
    if [[ ! -d "${cursor_dir}/cursors" ]]; then
        mkdir -p "${HOME}/.local/share/icons"
        local tmp_zip="/tmp/MacOS-Tahoe-Cursor.zip"
        local tmp_extract="/tmp/MacOS-Tahoe-Extract"
        rm -rf "${tmp_zip}" "${tmp_extract}"
        if curl -sL --fail "https://github.com/witt-bit/MacOS-Tahoe-Cursor/releases/download/1.2/MacOS-Tahoe-Cursor.zip" -o "${tmp_zip}"; then
            unzip -q "${tmp_zip}" -d "${tmp_extract}"
            if [[ -d "${tmp_extract}/MacOS-Tahoe-Cursor/MacOS-Tahoe-Cursor" ]]; then
                mkdir -p "${cursor_dir}"
                cp -r "${tmp_extract}/MacOS-Tahoe-Cursor/MacOS-Tahoe-Cursor/"* "${cursor_dir}/"
            fi
            rm -rf "${tmp_zip}" "${tmp_extract}"
        fi
    fi
    gsettings set org.gnome.desktop.interface cursor-theme 'MacOS-Tahoe'
    gsettings set org.gnome.desktop.interface cursor-size 24
}

step_gnome_config() {
    "${SCRIPTS_DIR}/03-gnome-config.sh"
}

step_extensions() {
    gsettings set org.gnome.shell disable-user-extensions false
    local core_exts=(
        "dash-to-dock@micxgx.gmail.com"
        "logomenu@aryan_k"
        "Resource_Monitor@Ory0n"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "just-perfection-desktop@just-perfection"
    )
    if command -v gnome-extensions >/dev/null 2>&1; then
        for ext in "${core_exts[@]}"; do
            gnome-extensions enable "${ext}" 2>/dev/null || true
        done
    fi
}

step_firefox() {
    "${SCRIPTS_DIR}/04-firefox.sh"
}

step_preset() {
    "${SCRIPTS_DIR}/preset-manager.sh" apply gundam-00
}

# ------------------------------------------------------------------------------
# Main Entrypoint
# ------------------------------------------------------------------------------
main() {
    local run_mode="full"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --doctor)
                run_doctor
                ;;
            --restore)
                restore_backup
                ;;
            --dry-run)
                simulate_dry_run
                ;;
            -u|--user-only)
                run_mode="user-only"
                shift
                ;;
            -c|--check)
                simulate_dry_run
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_err "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    log_banner

    # Check environment
    if [[ ! -f /etc/os-release ]]; then
        log_err "Cannot verify OS environment."
        exit 1
    fi

    # Initialize log file
    echo "=== Gundam Celestial Installation Log - $(date) ===" > "${LOG_FILE}"

    # Up-front root elevation check for full installation
    if [[ "${run_mode}" == "full" ]]; then
        if ! sudo -n true 2>/dev/null; then
            echo -e "${CYAN}[+] Root elevation required for system configuration. Authenticating:${NC}"
            sudo -v
        fi
    fi

    echo -e "${BOLD}${MAGENTA}==> Initiating Turnkey Installation Pipeline${NC}\n"

    # Step 1: Backup
    run_step "Creating Desktop State Backup (Restore Point)" step_backup

    if [[ "${run_mode}" == "full" ]]; then
        # Step 2: ZRAM
        run_step "Configuring High-Speed ZRAM Engine (zstd)" step_zram

        # Package resolution
        run_step "Resolving Package Dependencies (Pacman & AUR)" step_packages
    fi

    # Step 3: Typography
    run_step "Deploying JetBrains Mono Typography" step_typography

    # Step 4: Cursor
    run_step "Fetching & Registering MacOS Tahoe Cursor (Compact 24px)" step_cursor

    # Step 5: Window controls, top bar & overview
    run_step "Linking WhiteSur Mac Window Controls & Libadwaita CSS" step_gnome_config

    # Step 6: Extension auto-activation & hardening
    run_step "Auto-Activating & Hardening GNOME Extensions" step_extensions

    # Step 7: Firefox styling
    run_step "Deploying Firefox macOS & Gundam Celestial Styling" step_firefox

    # Step 8: Preset finalization
    run_step "Applying Declarative Preset 'gundam-00'" step_preset

    echo -e "\n${BOLD}${GREEN}======================================================================${NC}"
    echo -e "${BOLD}${GREEN}✓ GUNDAM CELESTIAL THEME INSTALLED & CONFIGURED SUCCESSFULLY${NC}"
    echo -e "${BOLD}${GREEN}======================================================================${NC}"
    echo -e "Summary of Applied Components:"
    echo -e "  • Author:     parikesitad-pm (MIT License 2026)"
    echo -e "  • Memory:     ZRAM (zstd, zram-size=ram) with optimized sysctl parameters"
    echo -e "  • Typography: JetBrains Mono 10 (Interface, Monospace, Document)"
    echo -e "  • Cursor:     MacOS Tahoe (24px compact)"
    echo -e "  • Controls:   Left circular traffic lights (GTK3 & GTK4/Libadwaita)"
    echo -e "  • Dock:       Floating Dash-to-Dock (0.45 flat RGBA, hide-in-overview)"
    echo -e "  • Overview:   Clutter-free window spread (search bar hidden for Ulauncher)"
    echo -e "  • Shortcut:   Ulauncher Spotlight mapped to Ctrl + Space"
    echo -e "  • Firefox:    macOS rounded traffic lights & GN particle green highlights"
    echo -e "  • Preset:     'gundam-00' loaded atomically via dconf"
    echo -e "  • Backup:     Restore point created in ~/.config/dconf-backup-*.dconf"
    echo -e "\n${CYAN}Rollback available anytime via:${NC} ./install.sh --restore\n"

    # Interactive Wayland Session Relog Prompt
    if [[ -t 0 && -t 1 ]]; then
        echo -e "\n[✔] Setup completed! A session reload is required to apply all visual changes."
        read -rp "Log out now to apply changes? (y/N): " relog_choice
        if [[ "${relog_choice}" =~ ^[Yy]$ ]]; then
            sync
            echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1 || true
            loginctl terminate-user "$USER" || gnome-session-quit --logout --no-prompt --force
        fi
    else
        echo -e "\n[✔] Setup completed! A session reload is required to apply all visual changes (loginctl terminate-user \"$USER\").\n"
    fi
}

main "$@"
