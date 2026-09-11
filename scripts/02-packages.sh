#!/usr/bin/env bash
# ==============================================================================
# Gundam Celestial GNOME Theme - Module 02: Package & Dependency Management
# Target: Manjaro Linux (Pacman + AUR/yay)
# Dependencies: Nordzy-dark icons, Dash-to-Dock, Logo Menu, Resource Monitor
# ==============================================================================

set -euo pipefail

# Visual formatting
BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[PKG INFO]${NC} $*"; }
log_ok()   { echo -e "${GREEN}[PKG OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[PKG WARN]${NC} $*"; }
log_err()  { echo -e "${RED}[PKG ERROR]${NC} $*" >&2; }

echo -e "${BOLD}${CYAN}==> [02/03] Resolving Package Dependencies (Pacman & AUR)${NC}"

# Detect AUR helper
AUR_HELPER=""
if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
fi

if [[ -z "${AUR_HELPER}" ]]; then
    log_warn "No AUR helper (yay or paru) detected. Packages available only in AUR must be built manually if missing."
else
    log_ok "Detected AUR helper: ${AUR_HELPER}"
fi

# Define required packages
# Official Arch/Manjaro repository packages
OFFICIAL_PKGS=(
    "zram-generator"
    "gnome-shell-extension-dash-to-dock"
    "unzip"
    "glib2"
)

# AUR Packages
AUR_PKGS=(
    "nordzy-icon-theme"
    "gnome-shell-extension-logo-menu"
    "gnome-shell-extension-resource-monitor"
)

# 1. Filter and install official repository packages
MISSING_OFFICIAL=()
for pkg in "${OFFICIAL_PKGS[@]}"; do
    if pacman -Q "${pkg}" >/dev/null 2>&1; then
        log_ok "Official package '${pkg}' is already installed."
    else
        MISSING_OFFICIAL+=("${pkg}")
    fi
done

if [[ ${#MISSING_OFFICIAL[@]} -gt 0 ]]; then
    log_info "Installing missing official packages: ${MISSING_OFFICIAL[*]}"
    sudo pacman -S --needed --noconfirm "${MISSING_OFFICIAL[@]}"
    log_ok "Official packages installed."
else
    log_ok "All official packages are up to date."
fi

# 2. Filter and install AUR packages
MISSING_AUR=()
for pkg in "${AUR_PKGS[@]}"; do
    # Check if package is installed under its exact name or git variant
    if pacman -Q "${pkg}" >/dev/null 2>&1 || pacman -Q "${pkg}-git" >/dev/null 2>&1; then
        log_ok "AUR package '${pkg}' is already installed."
    else
        MISSING_AUR+=("${pkg}")
    fi
done

if [[ ${#MISSING_AUR[@]} -gt 0 ]]; then
    if [[ -n "${AUR_HELPER}" ]]; then
        log_info "Installing missing AUR packages via ${AUR_HELPER}: ${MISSING_AUR[*]}"
        "${AUR_HELPER}" -S --needed --noconfirm "${MISSING_AUR[@]}"
        log_ok "AUR packages installed successfully."
    else
        log_err "Missing AUR packages: ${MISSING_AUR[*]}"
        log_err "Please install an AUR helper such as 'yay' or manually build these packages from AUR."
        exit 1
    fi
else
    log_ok "All AUR dependencies are satisfied."
fi

# 3. Validation
log_ok "Dependency verification complete. All necessary packages are installed."
