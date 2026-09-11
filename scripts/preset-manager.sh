#!/usr/bin/env bash
# ==============================================================================
# Project:     gundam-celestial-gnome-theme
# Module:      Preset Management Utility (scripts/preset-manager.sh)
# Target:      Manjaro 26.1.2 (Bian-May) | GNOME Shell 50.4 (Wayland)
# Author:      parikesitad-pm
# License:     MIT License (c) 2026
# Description: Declarative dconf preset manager supporting atomic apply & export
#              with portable dynamic repository path tokenization (@REPO_DIR@)
# ==============================================================================

set -euo pipefail

# Visual formatting
BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[PRESET INFO]${NC} $*"; }
log_ok()   { echo -e "${GREEN}[PRESET OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[PRESET WARN]${NC} $*"; }
log_err()  { echo -e "${RED}[PRESET ERROR]${NC} $*" >&2; }

# Dynamic repository and presets directory resolution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="${REPO_DIR:-$(cd "${SCRIPT_DIR}/.." && pwd)}"
PRESETS_DIR="${REPO_DIR}/presets"

mkdir -p "${PRESETS_DIR}"

show_help() {
    cat <<EOF
${BOLD}Gundam Celestial Being - Declarative Preset Manager${NC}
Author: parikesitad-pm | License: MIT (c) 2026

Usage: $(basename "$0") <command> [preset-name]

Commands:
  apply <preset-name>   Apply declarative dconf preset (e.g., 'gundam-00')
  export <preset-name>  Snapshot active isolated GNOME UI state into a preset
  list                  List all available presets in ./presets/
  help                  Show this help screen

Examples:
  $0 apply gundam-00
  $0 export my-custom-preset
EOF
}

# ------------------------------------------------------------------------------
# Subcommand: Apply Preset
# ------------------------------------------------------------------------------
apply_preset() {
    local name="$1"
    # Normalize name (strip trailing .dconf if provided)
    name="${name%.dconf}"
    local file="${PRESETS_DIR}/${name}.dconf"

    if [[ ! -f "${file}" ]]; then
        log_err "Preset file not found: ${file}"
        exit 1
    fi

    log_info "Applying preset '${name}' from: ${file}"
    log_info "Substituting dynamic repository path: ${REPO_DIR}"

    # Ensure wallpapers are deployed to persistent user background directory with 644 permissions
    local bg_dir="${HOME}/.local/share/backgrounds"
    mkdir -p "${bg_dir}"
    for wp in gundam-dark.jpg gundam-light.jpg gundam-lock.jpg; do
        if [[ -f "${REPO_DIR}/assets/img/${wp}" ]]; then
            cp -f "${REPO_DIR}/assets/img/${wp}" "${bg_dir}/${wp}"
            chmod 644 "${bg_dir}/${wp}"
        fi
    done

    # Replace @REPO_DIR@ and {{REPO_DIR}} placeholders with actual absolute REPO_DIR
    local temp_conf
    temp_conf="$(mktemp)"
    sed -e "s|@REPO_DIR@|${REPO_DIR}|g" \
        -e "s|{{REPO_DIR}}|${REPO_DIR}|g" \
        "${file}" > "${temp_conf}"

    # Load into dconf root
    if dconf load / < "${temp_conf}"; then
        log_ok "dconf state successfully loaded."
    else
        log_err "Failed to load dconf preset."
        rm -f "${temp_conf}"
        exit 1
    fi
    rm -f "${temp_conf}"

    # Verify and enable extensions defined in preset if gnome-extensions is present
    if command -v gnome-extensions >/dev/null 2>&1; then
        local target_exts=(
            "user-theme@gnome-shell-extensions.gcampax.github.com"
            "dash-to-dock@micxgx.gmail.com"
            "logomenu@aryan_k"
            "Resource_Monitor@Ory0n"
            "just-perfection-desktop@just-perfection"
        )
        for ext in "${target_exts[@]}"; do
            if gnome-extensions list 2>/dev/null | grep -qx "${ext}"; then
                gnome-extensions enable "${ext}" 2>/dev/null || true
                log_ok "Extension active: ${ext}"
            fi
        done
    fi

    log_ok "Preset '${name}' applied cleanly and verified."
}

# ------------------------------------------------------------------------------
# Subcommand: Export Preset
# ------------------------------------------------------------------------------
export_preset() {
    local name="$1"
    name="${name%.dconf}"
    local file="${PRESETS_DIR}/${name}.dconf"

    log_info "Exporting current UI state to preset '${name}'..."

    # Define target schemas to isolate (prevents user history or unrelated bloat)
    local target_paths=(
        "/org/gnome/desktop/wm/preferences/"
        "/org/gnome/desktop/interface/"
        "/org/gnome/desktop/background/"
        "/org/gnome/desktop/screensaver/"
        "/org/gnome/shell/"
        "/org/gnome/shell/extensions/dash-to-dock/"
        "/org/gnome/shell/extensions/logo-menu/"
        "/org/gnome/shell/extensions/resource-monitor/"
        "/org/gnome/shell/extensions/just-perfection/"
        "/org/gnome/shell/extensions/user-theme/"
    )

    local temp_dump
    temp_dump="$(mktemp)"

    # Header with author watermark
    cat <<EOF > "${temp_dump}"
# ==============================================================================
# Project:     gundam-celestial-gnome-theme
# Preset:      ${name}
# Target:      Manjaro 26.1.2 (Bian-May) | GNOME Shell 50.4 (Wayland)
# Author:      parikesitad-pm
# License:     MIT License (c) 2026
# Exported At: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
# ==============================================================================

EOF

    # Dump target paths
    for path in "${target_paths[@]}"; do
        local dump_data
        dump_data="$(dconf dump "${path}" 2>/dev/null || true)"
        if [[ -n "${dump_data}" ]]; then
            # Strip trailing slash for section heading
            local section_header="${path#/}"
            section_header="${section_header%/}"
            echo "[${section_header}]" >> "${temp_dump}"
            echo "${dump_data}" >> "${temp_dump}"
            echo "" >> "${temp_dump}"
        fi
    done

    # Replace absolute REPO_DIR with portable @REPO_DIR@ token
    sed -i "s|${REPO_DIR}|@REPO_DIR@|g" "${temp_dump}"

    # Clean up empty sections if any
    mv "${temp_dump}" "${file}"
    log_ok "Preset successfully exported to: ${file}"
}

# ------------------------------------------------------------------------------
# Subcommand: List Presets
# ------------------------------------------------------------------------------
list_presets() {
    echo -e "${BOLD}Available Presets in ${PRESETS_DIR}:${NC}"
    local count=0
    for p in "${PRESETS_DIR}"/*.dconf; do
        if [[ -f "${p}" ]]; then
            local bname
            bname="$(basename "${p}" .dconf)"
            echo "  • ${bname} (${p})"
            count=$((count + 1))
        fi
    done
    if [[ ${count} -eq 0 ]]; then
        echo "  (No presets found)"
    fi
}

# ------------------------------------------------------------------------------
# CLI Router
# ------------------------------------------------------------------------------
COMMAND="${1:-}"

case "${COMMAND}" in
    apply)
        if [[ -z "${2:-}" ]]; then
            log_err "Missing preset name. Usage: $0 apply <preset-name>"
            exit 1
        fi
        apply_preset "$2"
        ;;
    export)
        if [[ -z "${2:-}" ]]; then
            log_err "Missing preset name. Usage: $0 export <preset-name>"
            exit 1
        fi
        export_preset "$2"
        ;;
    list)
        list_presets
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        log_err "Unknown command: '${COMMAND}'"
        show_help
        exit 1
        ;;
esac
