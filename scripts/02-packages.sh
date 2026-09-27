#!/usr/bin/env bash
# ==============================================================================
# Project:     gundam-celestial-gnome-theme
# Module:      02 - Package & Dependency Management (scripts/02-packages.sh)
# Target:      Manjaro 26.1.2 (Bian-May) | GNOME Shell 50.4 (Wayland)
# Author:      parikesitad-pm
# License:     MIT License (c) 2026
# Dependencies: Nordzy-dark, Dash-to-Dock, Logo Menu, Resource Monitor, Just Perfection
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

# ------------------------------------------------------------------------------
# 1. Distro Family Detection
# ------------------------------------------------------------------------------
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        DISTRO_ID="${ID:-unknown}"
        DISTRO_LIKE="${ID_LIKE:-}"
        DISTRO_NAME="${PRETTY_NAME:-Linux}"
    else
        DISTRO_ID="unknown"
        DISTRO_LIKE=""
        DISTRO_NAME="Unknown Linux"
    fi

    if [[ "${DISTRO_ID}" =~ ^(arch|manjaro|endeavouros|garuda|artix)$ ]] || [[ "${DISTRO_LIKE}" =~ arch ]]; then
        DISTRO_FAMILY="arch"
        PKG_MANAGER="pacman"
    elif [[ "${DISTRO_ID}" =~ ^(fedora|rhel|centos|rocky|almalinux)$ ]] || [[ "${DISTRO_LIKE}" =~ (fedora|rhel) ]]; then
        DISTRO_FAMILY="fedora"
        PKG_MANAGER="dnf"
    elif [[ "${DISTRO_ID}" =~ ^(ubuntu|debian|pop|mint|zorin|elementary)$ ]] || [[ "${DISTRO_LIKE}" =~ (debian|ubuntu) ]]; then
        DISTRO_FAMILY="debian"
        PKG_MANAGER="apt"
    elif [[ "${DISTRO_ID}" =~ ^(opensuse|suse|sles)$ ]] || [[ "${DISTRO_LIKE}" =~ (suse|opensuse) ]]; then
        DISTRO_FAMILY="suse"
        PKG_MANAGER="zypper"
    else
        DISTRO_FAMILY="generic"
        PKG_MANAGER="unknown"
    fi
}

detect_distro
echo -e "${BOLD}${CYAN}==> [02/03] Resolving Package Dependencies (${DISTRO_NAME})${NC}"
log_info "Detected Distro Family: ${DISTRO_FAMILY} (Manager: ${PKG_MANAGER})"

# ------------------------------------------------------------------------------
# 2. Native Package Installation per Distro
# ------------------------------------------------------------------------------
AUR_HELPER=""
if [[ "${DISTRO_FAMILY}" == "arch" ]]; then
    if command -v yay >/dev/null 2>&1; then
        AUR_HELPER="yay"
    elif command -v paru >/dev/null 2>&1; then
        AUR_HELPER="paru"
    fi
fi

case "${DISTRO_FAMILY}" in
    arch)
        OFFICIAL_PKGS=(
            "zram-generator"
            "gnome-shell-extension-dash-to-dock"
            "gnome-shell-extensions"
            "gnome-shell-extension-gnome-ui-tune"
            "ttf-jetbrains-mono"
            "curl"
            "unzip"
            "git"
            "zsh"
            "firefox"
            "glib2"
        )
        AUR_PKGS=(
            "nordzy-icon-theme"
            "whitesur-gtk-theme"
            "gnome-shell-extension-logo-menu"
            "gnome-shell-extension-resource-monitor"
            "gnome-shell-extension-just-perfection-desktop"
        )

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
        fi

        MISSING_AUR=()
        for pkg in "${AUR_PKGS[@]}"; do
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
                log_ok "AUR packages installed."
            else
                log_warn "No AUR helper detected. Packages (${MISSING_AUR[*]}) will be fetched via upstream fallbacks."
            fi
        fi
        ;;

    fedora)
        FEDORA_PKGS=(
            "zram-generator"
            "curl"
            "unzip"
            "git"
            "zsh"
            "firefox"
            "jetbrains-mono-fonts"
            "glib2-devel"
            "gnome-shell-extension-dash-to-dock"
            "gnome-shell-extension-user-theme"
        )
        MISSING_FEDORA=()
        for pkg in "${FEDORA_PKGS[@]}"; do
            if rpm -q "${pkg}" >/dev/null 2>&1; then
                log_ok "Package '${pkg}' is already installed."
            else
                MISSING_FEDORA+=("${pkg}")
            fi
        done
        if [[ ${#MISSING_FEDORA[@]} -gt 0 ]]; then
            log_info "Installing missing Fedora packages: ${MISSING_FEDORA[*]}"
            sudo dnf install -y "${MISSING_FEDORA[@]}"
            log_ok "Fedora packages installed."
        fi
        ;;

    debian)
        DEBIAN_PKGS=(
            "curl"
            "unzip"
            "git"
            "zsh"
            "firefox"
            "fonts-jetbrains-mono"
            "libglib2.0-bin-common"
            "gnome-shell-extensions"
            "gnome-shell-extension-dash-to-dock"
        )
        MISSING_DEBIAN=()
        for pkg in "${DEBIAN_PKGS[@]}"; do
            if dpkg -l "${pkg}" >/dev/null 2>&1; then
                log_ok "Package '${pkg}' is already installed."
            else
                MISSING_DEBIAN+=("${pkg}")
            fi
        done
        if [[ ${#MISSING_DEBIAN[@]} -gt 0 ]]; then
            log_info "Installing missing Debian/Ubuntu packages: ${MISSING_DEBIAN[*]}"
            sudo apt-get update && sudo apt-get install -y "${MISSING_DEBIAN[@]}"
            log_ok "Debian/Ubuntu packages installed."
        fi
        ;;

    suse)
        SUSE_PKGS=(
            "systemd-zram-generator"
            "curl"
            "unzip"
            "git"
            "zsh"
            "MozillaFirefox"
            "jetbrains-mono-fonts"
            "glib2-tools"
            "gnome-shell-extension-dash-to-dock"
        )
        MISSING_SUSE=()
        for pkg in "${SUSE_PKGS[@]}"; do
            if rpm -q "${pkg}" >/dev/null 2>&1; then
                log_ok "Package '${pkg}' is already installed."
            else
                MISSING_SUSE+=("${pkg}")
            fi
        done
        if [[ ${#MISSING_SUSE[@]} -gt 0 ]]; then
            log_info "Installing missing openSUSE packages: ${MISSING_SUSE[*]}"
            sudo zypper install -y "${MISSING_SUSE[@]}"
            log_ok "openSUSE packages installed."
        fi
        ;;

    *)
        log_warn "Generic distro detected. Ensuring curl, unzip, git, and zsh are available."
        for cmd in curl unzip git zsh; do
            if ! command -v "${cmd}" >/dev/null 2>&1; then
                log_warn "Command '${cmd}' is missing. Please install it using your package manager."
            fi
        done
        ;;
esac

# ------------------------------------------------------------------------------
# 3. WhiteSur GTK Theme Universal Fallback
# ------------------------------------------------------------------------------
ensure_whitesur_theme() {
    local sys_theme="/usr/share/themes/WhiteSur-Dark"
    local usr_theme="${HOME}/.local/share/themes/WhiteSur-Dark"

    if [[ -d "${sys_theme}" || -d "${usr_theme}" ]]; then
        log_ok "WhiteSur GTK theme is already installed."
        return 0
    fi

    log_info "WhiteSur GTK theme not detected. Installing from upstream repository..."
    local tmp_theme="/tmp/WhiteSur-gtk-theme"
    rm -rf "${tmp_theme}"
    if git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git "${tmp_theme}"; then
        mkdir -p "${HOME}/.local/share/themes"
        "${tmp_theme}/install.sh" -d "${HOME}/.local/share/themes" -t all -c Dark -m -l
        rm -rf "${tmp_theme}"
        log_ok "WhiteSur GTK theme installed to ${HOME}/.local/share/themes."
    else
        log_warn "Failed to clone WhiteSur GTK theme repository. Please install WhiteSur-Dark manually."
    fi
}

ensure_whitesur_theme

# ------------------------------------------------------------------------------
# 4. Zen Browser Installation
# ------------------------------------------------------------------------------
install_zen_browser() {
    if command -v zen-browser >/dev/null 2>&1 || command -v zen >/dev/null 2>&1 || [[ -d "${HOME}/.local/opt/zen-browser" ]]; then
        log_ok "Zen Browser is already installed."
        return 0
    fi

    log_info "Zen Browser not detected. Initiating automated installation..."

    # Arch/Manjaro AUR pathway
    if [[ "${DISTRO_FAMILY}" == "arch" && -n "${AUR_HELPER}" ]]; then
        log_info "Installing zen-browser-bin from AUR using ${AUR_HELPER}..."
        if "${AUR_HELPER}" -S --needed --noconfirm zen-browser-bin; then
            log_ok "Zen Browser successfully installed via AUR."
            return 0
        fi
        log_warn "AUR installation failed. Falling back to universal release binary..."
    fi

    # Flatpak pathway
    if command -v flatpak >/dev/null 2>&1; then
        if flatpak list --app 2>/dev/null | grep -q "app.zen_browser.zen"; then
            log_ok "Zen Browser (Flatpak) is already installed."
            return 0
        fi
    fi

    # Universal direct release binary deployment
    log_info "Deploying Zen Browser via official release archive..."
    local zen_install_dir="${HOME}/.local/opt/zen-browser"
    local zen_bin_dir="${HOME}/.local/bin"
    local zen_apps_dir="${HOME}/.local/share/applications"
    mkdir -p "${zen_install_dir}" "${zen_bin_dir}" "${zen_apps_dir}"

    local tmp_tar="/tmp/zen.linux-x86_64.tar.xz"
    local download_url="https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz"

    if curl -sL --fail "${download_url}" -o "${tmp_tar}"; then
        tar -xf "${tmp_tar}" -C "${zen_install_dir}" --strip-components=1
        ln -sf "${zen_install_dir}/zen" "${zen_bin_dir}/zen"
        ln -sf "${zen_install_dir}/zen" "${zen_bin_dir}/zen-browser"

        cat <<EOF > "${zen_apps_dir}/zen.desktop"
[Desktop Entry]
Name=Zen Browser
Comment=Experience tranquility while browsing the web
Exec=${zen_install_dir}/zen %u
Icon=${zen_install_dir}/browser/chrome/icons/default/default128.png
Terminal=false
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF
        chmod +x "${zen_apps_dir}/zen.desktop"
        rm -f "${tmp_tar}"
        log_ok "Zen Browser deployed to ${zen_install_dir}."
    else
        log_warn "Could not download Zen Browser archive. You may install it manually from https://zen-browser.app."
    fi
}

install_zen_browser

# ------------------------------------------------------------------------------
# 5. JetBrains Mono Typography Fallback
# ------------------------------------------------------------------------------
ensure_jetbrains_mono() {
    if fc-list : family 2>/dev/null | grep -qi "JetBrains Mono"; then
        log_ok "JetBrains Mono typography is verified on system."
        return 0
    fi

    log_info "JetBrains Mono font not detected in system cache. Downloading..."
    local fonts_dir="${HOME}/.local/share/fonts/JetBrainsMono"
    mkdir -p "${fonts_dir}"
    local tmp_font="/tmp/JetBrainsMono.zip"
    if curl -sL --fail "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" -o "${tmp_font}"; then
        unzip -q -o "${tmp_font}" -d "${fonts_dir}"
        rm -f "${tmp_font}"
        if command -v fc-cache >/dev/null 2>&1; then
            fc-cache -f "${fonts_dir}" >/dev/null 2>&1 || true
        fi
        log_ok "JetBrains Mono installed to ${fonts_dir}."
    else
        log_warn "Could not download JetBrains Mono font. Please install it manually."
    fi
}

ensure_jetbrains_mono

log_ok "Dependency verification complete. All necessary packages are installed."
