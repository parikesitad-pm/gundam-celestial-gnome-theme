#!/usr/bin/env bash
# ==============================================================================
# GUNDAM CELESTIAL BEING - GNOME WORKSTATION DOTFILES
# ==============================================================================
# Target: Manjaro Linux (Bian-May) with GNOME Shell 50.4 (Wayland)
# Hardware Profile: 8GB Physical RAM Workstation
# Strategy: ZRAM (zstd, zram-size=ram), 0 runtime daemons, SVG vector icons
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

log_banner() {
    echo -e "${CYAN}${BOLD}"
    cat <<'EOF'
   ____ _   _ _   _ ____    _    __  __
  / ___| | | | \ | |  _ \  / \  |  \/  |
 | |  _| | | |  \| | | | |/ _ \ | |\/| |
 | |_| | |_| | |\  | |_| / ___ \| |  | |
  \____|\___/|_| \_|____/_/   \_\_|  |_|
   CELESTIAL BEING - MANJARO GNOME 50 (WAYLAND)
EOF
    echo -e "${NC}"
    echo -e "${BOLD}Repository Path:${NC} ${REPO_DIR}"
    echo -e "${BOLD}Target System:${NC}   Manjaro Linux | GNOME 50.4 (Wayland) | 8GB RAM Optimization"
    echo -e "${BLUE}----------------------------------------------------------------------${NC}"
}

show_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Automated dotfiles setup for Gundam Celestial GNOME Theme on Manjaro Linux.

Options:
  -u, --user-only   Apply user-space GNOME configuration only (skip root ZRAM and packages)
  -c, --check       Perform non-destructive environment, asset, and config audit
  -h, --help        Display this help message and exit

Default:
  Runs the full sequential installation (ZRAM -> Packages -> GNOME Config).
EOF
}

log_step() { echo -e "\n${BOLD}${MAGENTA}==> [STEP]${NC} ${BOLD}$*${NC}"; }
log_info() { echo -e "${CYAN}[INFO]${NC} $*"; }
log_ok()   { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_err()  { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ------------------------------------------------------------------------------
# Pre-flight Checks & Asset Verification
# ------------------------------------------------------------------------------
verify_environment() {
    log_step "Verifying Environment & Prerequisites"

    # OS Verification
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        log_info "Detected OS: ${PRETTY_NAME:-Linux}"
        if [[ "${ID:-}" != "manjaro" && "${ID_LIKE:-}" != *"arch"* ]]; then
            log_warn "This setup is tailored for Manjaro/Arch Linux. Proceed with caution."
        fi
    fi

    # Session type
    local session="${XDG_SESSION_TYPE:-unknown}"
    log_info "Desktop Session: ${session}"
    if [[ "${session}" != "wayland" ]]; then
        log_warn "Current session is '${session}'. This profile is optimized specifically for Wayland."
    fi

    # GNOME Shell version
    if command -v gnome-shell >/dev/null 2>&1; then
        local gver
        gver="$(gnome-shell --version 2>&1 || true)"
        log_info "Shell: ${gver}"
    else
        log_err "GNOME Shell was not detected on this system."
        exit 1
    fi

    # Sudo verification if running full setup
    if [[ "${RUN_MODE}" == "full" ]]; then
        if ! sudo -n true 2>/dev/null; then
            if [[ -t 0 ]]; then
                log_info "Elevated privileges required for ZRAM and package configuration."
                sudo -v
            else
                log_warn "Non-interactive shell without cached sudo credentials. Root tasks may prompt."
            fi
        else
            log_ok "Sudo privileges validated and cached."
        fi
    fi
}

verify_assets() {
    log_step "Verifying Repository Graphical Assets"

    local dark_wp="${REPO_DIR}/assets/img/gundam-dark.jpg"
    local light_wp="${REPO_DIR}/assets/img/gundam-light.jpg"
    local lock_wp="${REPO_DIR}/assets/img/gundam-lock.jpg"
    local cb_logo="${REPO_DIR}/assets/img/logo/cb.png"

    # Verify wallpapers
    if [[ -f "${dark_wp}" ]]; then
        log_ok "Dark wallpaper located: ${dark_wp}"
    else
        log_err "Missing dark wallpaper: ${dark_wp}"
        exit 1
    fi

    if [[ -f "${light_wp}" ]]; then
        log_ok "Light wallpaper located: ${light_wp}"
    else
        log_err "Missing light wallpaper: ${light_wp}"
        exit 1
    fi

    if [[ -f "${lock_wp}" ]]; then
        log_ok "Lockscreen wallpaper located: ${lock_wp}"
    else
        log_warn "Lockscreen wallpaper missing: ${lock_wp}"
        log_warn "Falling back lockscreen to: ${dark_wp}"
    fi

    # Verify Celestial Being logo with graceful fallback warning
    if [[ -f "${cb_logo}" ]]; then
        log_ok "Celestial Being logo located: ${cb_logo}"
    else
        log_warn "------------------------------------------------------------"
        log_warn "CRITICAL WARNING: Celestial Being logo missing at:"
        log_warn "${cb_logo}"
        log_warn "The Logo Menu extension will fall back to default icon."
        log_warn "Ensure assets/img/logo/cb.png is restored."
        log_warn "------------------------------------------------------------"
    fi
}

audit_system() {
    log_step "System & GNOME Audit (Read-Only Check)"

    echo -e "${BOLD}1. ZRAM Status:${NC}"
    if command -v zramctl >/dev/null 2>&1; then
        zramctl --output NAME,ALGORITHM,DISKSIZE,DATA,COMPR,TOTAL,MOUNTPOINT || true
    fi

    echo -e "\n${BOLD}2. Key GNOME Desktop Settings:${NC}"
    echo "  Window buttons:  $(gsettings get org.gnome.desktop.wm.preferences button-layout 2>/dev/null || echo 'N/A')"
    echo "  Color scheme:    $(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo 'N/A')"
    echo "  Icon theme:      $(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null || echo 'N/A')"
    echo "  Dark wallpaper:  $(gsettings get org.gnome.desktop.background picture-uri-dark 2>/dev/null || echo 'N/A')"
    echo "  Light wallpaper: $(gsettings get org.gnome.desktop.background picture-uri 2>/dev/null || echo 'N/A')"
    echo "  Lockscreen:      $(gsettings get org.gnome.desktop.screensaver picture-uri 2>/dev/null || echo 'N/A')"

    echo -e "\n${BOLD}3. Extensions Status:${NC}"
    if command -v gnome-extensions >/dev/null 2>&1; then
        for ext in "dash-to-dock@micxgx.gmail.com" "logomenu@aryan_k" "Resource_Monitor@Ory0n"; do
            local state
            state="$(gnome-extensions info "${ext}" 2>/dev/null | grep "State:" || echo "State: Not installed")"
            echo "  ${ext}: ${state}"
        done
    fi

    log_ok "System audit complete."
}

# ------------------------------------------------------------------------------
# Modular Execution
# ------------------------------------------------------------------------------
run_modules() {
    local scripts_dir="${REPO_DIR}/scripts"

    # Ensure executable permissions on modules
    chmod +x "${scripts_dir}"/*.sh 2>/dev/null || true

    if [[ "${RUN_MODE}" == "full" ]]; then
        # Step 1: ZRAM Configuration
        log_step "Executing Module 01: ZRAM Memory Strategy (8GB Optimization)"
        "${scripts_dir}/01-zram.sh"

        # Step 2: Package & Dependency Management
        log_step "Executing Module 02: Package Resolution (Pacman & AUR)"
        "${scripts_dir}/02-packages.sh"
    fi

    # Step 3: Declarative GNOME Configuration
    log_step "Executing Module 03: GNOME Shell Declarative Config"
    "${scripts_dir}/03-gnome-config.sh"
}

# ------------------------------------------------------------------------------
# Main Entrypoint
# ------------------------------------------------------------------------------
main() {
    RUN_MODE="full"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -u|--user-only)
                RUN_MODE="user-only"
                shift
                ;;
            -c|--check)
                RUN_MODE="check"
                shift
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
    verify_environment
    verify_assets

    if [[ "${RUN_MODE}" == "check" ]]; then
        audit_system
        exit 0
    fi

    run_modules

    echo -e "\n${BOLD}${GREEN}======================================================================${NC}"
    echo -e "${BOLD}${GREEN}✓ GUNDAM CELESTIAL THEME INSTALLED & CONFIGURED SUCCESSFULLY${NC}"
    echo -e "${BOLD}${GREEN}======================================================================${NC}"
    echo -e "Summary of Applied Architecture:"
    echo -e "  • Memory:   ZRAM (zstd, zram-size=ram) with optimized sysctl parameters"
    echo -e "  • Dock:     Floating, bottom-centered Dash-to-Dock with intelligent autohide"
    echo -e "  • UI:       macOS left window controls (close,minimize,maximize:)"
    echo -e "  • Theme:    Nordzy-dark pure SVG vector icon pack"
    echo -e "  • Top Bar:  Celestial Being logo menu replacing Activities + 3000ms CPU/RAM monitor"
    echo -e "  • Dynamic:  GNOME dark/light wallpapers dynamically bound via gsettings"
    echo -e "\n${CYAN}Note:${NC} On Wayland, if newly installed extensions do not render immediately,"
    echo -e "log out and log back in to reload the GNOME Shell session cleanly.\n"
}

main "$@"
