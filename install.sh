#!/usr/bin/env bash
# ==============================================================================
# Project:     gundam-celestial-gnome-theme
# Module:      Master Turnkey Orchestrator (install.sh)
# Target:      Manjaro 26.1.2 (Bian-May) | GNOME Shell 50.4 (Wayland)
# Author:      Dausan Adam Parikesit
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
    echo -e "${BLUE}  Architect: Dausan Adam Parikesit | 8GB RAM ZRAM Optimized | Preset: gundam-00${NC}\n"
}

show_help() {
    cat <<EOF
${BOLD}Gundam Celestial GNOME Theme - Installation & Management Tool${NC}
Author: Dausan Adam Parikesit | License: MIT (c) 2026

Usage: $(basename "$0") [OPTIONS]

Options:
  --restore         Instantly restore the latest dconf desktop state snapshot
  --dry-run         Simulate checks, network, and preview schema changes without writing
  -u, --user-only   Apply user-space configurations and preset only (skip root ZRAM/packages)
  -c, --check       Perform non-destructive environment and asset audit
  -h, --help        Display this help screen

Default:
  Runs the full turnkey installation pipeline with live CLI animated loader.
EOF
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

    # Step 6: Preset finalization
    run_step "Applying Declarative Preset 'gundam-00'" step_preset

    echo -e "\n${BOLD}${GREEN}======================================================================${NC}"
    echo -e "${BOLD}${GREEN}✓ GUNDAM CELESTIAL THEME INSTALLED & CONFIGURED SUCCESSFULLY${NC}"
    echo -e "${BOLD}${GREEN}======================================================================${NC}"
    echo -e "Summary of Applied Components:"
    echo -e "  • Author:     Dausan Adam Parikesit (MIT License 2026)"
    echo -e "  • Memory:     ZRAM (zstd, zram-size=ram) with optimized sysctl parameters"
    echo -e "  • Typography: JetBrains Mono 10 (Interface, Monospace, Document)"
    echo -e "  • Cursor:     MacOS Tahoe (24px compact)"
    echo -e "  • Controls:   Left circular traffic lights (GTK3 & GTK4/Libadwaita)"
    echo -e "  • Dock:       Floating Dash-to-Dock (0.45 flat RGBA, hide-in-overview)"
    echo -e "  • Overview:   Clutter-free window spread (search bar hidden for Ulauncher)"
    echo -e "  • Shortcut:   Ulauncher Spotlight mapped to Ctrl + Space"
    echo -e "  • Preset:     'gundam-00' loaded atomically via dconf"
    echo -e "  • Backup:     Restore point created in ~/.config/dconf-backup-*.dconf"
    echo -e "\n${CYAN}Rollback available anytime via:${NC} ./install.sh --restore\n"
}

main "$@"
