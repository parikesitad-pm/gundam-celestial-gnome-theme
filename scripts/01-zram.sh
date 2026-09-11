#!/usr/bin/env bash
# ==============================================================================
# Gundam Celestial GNOME Theme - Module 01: ZRAM Memory Strategy
# Target: Manjaro Linux (GNOME on Wayland, 8GB RAM Workstation)
# Philosophy: High performance, zero runtime daemons, zstd RAM compression
# ==============================================================================

set -euo pipefail

# Visual formatting
BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[ZRAM INFO]${NC} $*"; }
log_ok()   { echo -e "${GREEN}[ZRAM OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[ZRAM WARN]${NC} $*"; }
log_err()  { echo -e "${RED}[ZRAM ERROR]${NC} $*" >&2; }

echo -e "${BOLD}${CYAN}==> [01/03] Configuring ZRAM Memory Compression & Optimization${NC}"

# Check if sudo is available and can execute
can_elevate() {
    sudo -n true 2>/dev/null || [[ -t 0 ]]
}

if ! command -v sudo >/dev/null 2>&1; then
    log_err "sudo is required to configure systemd ZRAM generator."
    exit 1
fi

# 1. Verify zram-generator package is installed
if ! pacman -Q zram-generator >/dev/null 2>&1; then
    if can_elevate; then
        log_info "Installing zram-generator via pacman..."
        sudo pacman -S --noconfirm --needed zram-generator
        log_ok "zram-generator installed successfully."
    else
        log_warn "zram-generator is missing but cannot elevate non-interactively. Please install via: sudo pacman -S zram-generator"
    fi
else
    log_ok "zram-generator is already installed."
fi

# 2. Configure /etc/systemd/zram-generator.conf
ZRAM_CONF_FILE="/etc/systemd/zram-generator.conf"
ZRAM_TARGET_CONTENT=$(cat <<'EOF'
[zram0]
zram-size = ram
compression-algorithm = zstd
EOF
)

NEEDS_ZRAM_RELOAD=false

if [[ -f "${ZRAM_CONF_FILE}" ]] && \
   grep -q "zram-size = ram" "${ZRAM_CONF_FILE}" 2>/dev/null && \
   grep -q "compression-algorithm = zstd" "${ZRAM_CONF_FILE}" 2>/dev/null; then
    log_ok "ZRAM configuration is already up-to-date in ${ZRAM_CONF_FILE}."
else
    if can_elevate; then
        log_info "Updating ${ZRAM_CONF_FILE} to match Gundam Celestial specifications..."
        echo "${ZRAM_TARGET_CONTENT}" | sudo tee "${ZRAM_CONF_FILE}" >/dev/null
        NEEDS_ZRAM_RELOAD=true
    else
        log_warn "Cannot update ${ZRAM_CONF_FILE} without sudo elevation."
    fi
fi

# 3. Optimize kernel virtual memory parameters for 8GB RAM with ZRAM
# - vm.swappiness = 180: Aggressively prefer zram compressed RAM swap over dropping file caches or disk thrashing
# - vm.watermark_boost_factor = 0: Prevent memory fragmentation stalls
# - vm.watermark_scale_factor = 125: Moderate background memory reclaim
# - vm.page-cluster = 0: Single-page reads/writes for lowest ZRAM latency
SYSCTL_CONF_FILE="/etc/sysctl.d/99-zram.conf"
SYSCTL_TARGET_CONTENT=$(cat <<'EOF'
# Optimized memory parameters for 8GB RAM Workstation with ZRAM (zstd)
vm.swappiness = 180
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
vm.page-cluster = 0
EOF
)

if [[ -f "${SYSCTL_CONF_FILE}" ]] && \
   grep -q "vm.swappiness = 180" "${SYSCTL_CONF_FILE}" 2>/dev/null && \
   grep -q "vm.page-cluster = 0" "${SYSCTL_CONF_FILE}" 2>/dev/null; then
    log_ok "Sysctl ZRAM parameters are already optimized in ${SYSCTL_CONF_FILE}."
else
    if can_elevate; then
        log_info "Writing ${SYSCTL_CONF_FILE}..."
        echo "${SYSCTL_TARGET_CONTENT}" | sudo tee "${SYSCTL_CONF_FILE}" >/dev/null
        sudo sysctl --system >/dev/null
        log_ok "Sysctl parameters applied."
    else
        log_warn "Cannot write ${SYSCTL_CONF_FILE} without sudo elevation."
    fi
fi

# 4. Clean reload of systemd ZRAM services if configuration changed or zram0 not active
ZRAM_ACTIVE=false
if command -v zramctl >/dev/null 2>&1; then
    if zramctl --noheadings 2>/dev/null | grep -q "zram0"; then
        ZRAM_ACTIVE=true
    fi
fi

if [[ "${NEEDS_ZRAM_RELOAD}" == "true" ]] || [[ "${ZRAM_ACTIVE}" == "false" ]]; then
    if can_elevate; then
        log_info "Reloading systemd daemon and initiating ZRAM device..."
        sudo systemctl daemon-reload
        if sudo systemctl restart systemd-zram-setup@zram0.service 2>/dev/null; then
            log_ok "systemd-zram-setup@zram0.service restarted successfully."
        elif sudo systemctl restart /dev/zram0 2>/dev/null; then
            log_ok "/dev/zram0 service reloaded successfully."
        else
            log_warn "Failed to directly restart systemd-zram-setup unit; checking device status..."
        fi
    else
        log_warn "Service reload requires sudo privileges. Run 'sudo systemctl restart systemd-zram-setup@zram0.service' interactively."
    fi
fi

# 5. Output Verification
if command -v zramctl >/dev/null 2>&1; then
    echo -e "${BOLD}${GREEN}Active ZRAM Device Configuration:${NC}"
    zramctl --output NAME,ALGORITHM,DISKSIZE,DATA,COMPR,TOTAL,MOUNTPOINT
else
    log_warn "zramctl not found; verify swap status via swapon --show:"
    swapon --show
fi

log_ok "ZRAM 8GB memory strategy module complete."
