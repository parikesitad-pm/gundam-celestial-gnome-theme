#!/usr/bin/env bash
# ==============================================================================
# Project:     gundam-celestial-gnome-theme
# Module:      04 - Firefox macOS & Gundam Celestial Styling (scripts/04-firefox.sh)
# Target:      Manjaro 26.1.2 (Bian-May) | GNOME Shell 50.4 (Wayland)
# Author:      parikesitad-pm
# License:     MIT License (c) 2026
# Description: Configures Firefox with macOS window controls, Gundam colorways,
#              GN particle green tab highlights, and user.js stylesheets
# ==============================================================================

set -euo pipefail

# Visual formatting
BOLD='\033[1m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${CYAN}[FIREFOX INFO]${NC} $*"; }
log_ok()   { echo -e "${GREEN}[FIREFOX OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[FIREFOX WARN]${NC} $*"; }
log_err()  { echo -e "${RED}[FIREFOX ERROR]${NC} $*" >&2; }

echo -e "${BOLD}${CYAN}==> [04/04] Deploying Firefox macOS & Gundam Celestial Styling${NC}"

FIREFOX_DIR="${HOME}/.mozilla/firefox"

if [[ ! -d "${FIREFOX_DIR}" ]]; then
    log_warn "Firefox directory not found at ${FIREFOX_DIR}. Skipping Firefox styling."
    exit 0
fi

# ------------------------------------------------------------------------------
# 1. Profile Discovery
# ------------------------------------------------------------------------------
PROFILES=()

# Discover profiles matching *.default* or release
while IFS= read -r -d '' p_dir; do
    PROFILES+=("${p_dir}")
done < <(find "${FIREFOX_DIR}" -maxdepth 1 -mindepth 1 -type d \( -name "*.default*" -o -name "*release*" \) -print0 2>/dev/null)

if [[ ${#PROFILES[@]} -eq 0 ]]; then
    log_warn "No active Firefox default profiles located under ${FIREFOX_DIR}."
    exit 0
fi

# ------------------------------------------------------------------------------
# 2. Gundam Celestial userChrome Stylesheet
# ------------------------------------------------------------------------------
GUNDAM_FIREFOX_CSS=$(cat <<'EOF'
/* ==============================================================================
 * Gundam Celestial Being - Firefox macOS Style & Celestial Accents
 * Author: parikesitad-pm | License: MIT (c) 2026
 * ============================================================================== */

/* 1. Window Controls: Move to Left (macOS layout) */
#TabsToolbar .titlebar-buttonbox-container {
    order: -1 !important;
    margin-right: 8px !important;
    display: flex !important;
    align-items: center !important;
}

.titlebar-buttonbox {
    display: flex !important;
    flex-direction: row !important;
    align-items: center !important;
    margin-left: 6px !important;
    margin-right: 6px !important;
}

/* macOS Button Order: Close, Minimize, Maximize */
.titlebar-button.titlebar-close {
    order: 1 !important;
}
.titlebar-button.titlebar-min {
    order: 2 !important;
}
.titlebar-button.titlebar-max,
.titlebar-button.titlebar-restore {
    order: 3 !important;
}

/* 2. Window Controls Rounded Pill / Dot Appearance */
.titlebar-button {
    padding: 0 !important;
    margin: 0 4px !important;
    width: 13px !important;
    height: 13px !important;
    min-width: 13px !important;
    min-height: 13px !important;
    max-width: 13px !important;
    max-height: 13px !important;
    border-radius: 9999px !important;
    border: 1px solid rgba(0, 0, 0, 0.35) !important;
    box-shadow: none !important;
    appearance: none !important;
    background-size: 7px 7px !important;
    background-position: center !important;
    background-repeat: no-repeat !important;
    transition: all 120ms ease !important;
}

.titlebar-button > .toolbarbutton-icon {
    display: none !important;
    width: 0 !important;
    height: 0 !important;
}

/* Close Button: Gundam Crimson Red (#ED333B) */
.titlebar-button.titlebar-close {
    background-color: #ED333B !important;
    border-color: #C01C28 !important;
}
.titlebar-button.titlebar-close:hover {
    background-color: #E01B24 !important;
    background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="7" height="7" viewBox="0 0 7 7"><path fill="none" stroke="%234c0000" stroke-width="1.2" stroke-linecap="round" d="M1 1l5 5M6 1L1 6"/></svg>') !important;
}

/* Minimize Button: GN Solar Yellow (#F6D32D) */
.titlebar-button.titlebar-min {
    background-color: #F6D32D !important;
    border-color: #E5A50A !important;
}
.titlebar-button.titlebar-min:hover {
    background-color: #F5C211 !important;
    background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="7" height="7" viewBox="0 0 7 7"><path fill="none" stroke="%235a3900" stroke-width="1.2" stroke-linecap="round" d="M0.5 3.5h6"/></svg>') !important;
}

/* Maximize / Restore Button: Celestial Blue (#1A5FB4) */
.titlebar-button.titlebar-max,
.titlebar-button.titlebar-restore {
    background-color: #1A5FB4 !important;
    border-color: #154D91 !important;
}
.titlebar-button.titlebar-max:hover,
.titlebar-button.titlebar-restore:hover {
    background-color: #1C71D8 !important;
    background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="7" height="7" viewBox="0 0 7 7"><path fill="none" stroke="%230c2445" stroke-width="1.1" stroke-linecap="round" d="M1 2.5l2.5-2 2.5 2M1 4.5l2.5 2 2.5-2"/></svg>') !important;
}

/* Inactive window state */
:root:-moz-window-inactive .titlebar-button {
    background-color: rgba(255, 255, 255, 0.22) !important;
    border-color: rgba(0, 0, 0, 0.2) !important;
    background-image: none !important;
    opacity: 0.6 !important;
}

/* 3. Active Tab Line & GN Particle Green Selection Accent (#2EC27E) */
.tabbrowser-tab[selected="true"] .tab-background {
    border-top: 2px solid #2EC27E !important;
}
.tab-line[selected="true"],
.tabbrowser-tab[selected="true"] .tab-line {
    background-color: #2EC27E !important;
    height: 2px !important;
}
.tabbrowser-tab:hover:not([selected="true"]) .tab-background {
    background-color: rgba(46, 194, 126, 0.08) !important;
}
::selection {
    background-color: rgba(46, 194, 126, 0.35) !important;
    color: #ffffff !important;
}

/* 4. Titlebar Surface Blending with Flat Dark GTK Surfaces */
#navigator-toolbox,
#TabsToolbar,
#nav-bar {
    background-color: rgba(18, 22, 28, 0.95) !important;
    border: none !important;
}
EOF
)

# ------------------------------------------------------------------------------
# 3. Deploy to Profiles
# ------------------------------------------------------------------------------
for profile in "${PROFILES[@]}"; do
    log_info "Configuring Firefox profile: $(basename "${profile}")"

    # 1. Enable custom stylesheet loading in user.js
    USER_JS="${profile}/user.js"
    PREF_LINE='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'
    DRAW_TITLEBAR='user_pref("browser.tabs.drawInTitlebar", true);'

    if [[ -f "${USER_JS}" ]]; then
        if ! grep -Fq "toolkit.legacyUserProfileCustomizations.stylesheets" "${USER_JS}"; then
            echo "${PREF_LINE}" >> "${USER_JS}"
        fi
        if ! grep -Fq "browser.tabs.drawInTitlebar" "${USER_JS}"; then
            echo "${DRAW_TITLEBAR}" >> "${USER_JS}"
        fi
    else
        cat <<EOF > "${USER_JS}"
${PREF_LINE}
${DRAW_TITLEBAR}
EOF
    fi
    log_ok "Stylesheet customizations enabled in ${USER_JS}."

    # 2. Deploy userChrome.css
    CHROME_DIR="${profile}/chrome"
    mkdir -p "${CHROME_DIR}"

    TARGET_CSS="${CHROME_DIR}/userChrome.css"
    CUSTOM_CSS="${CHROME_DIR}/customChrome.css"

    # If userChrome.css exists, backup and update
    if [[ -f "${TARGET_CSS}" ]]; then
        if ! grep -Fq "Gundam Celestial Being" "${TARGET_CSS}"; then
            cp "${TARGET_CSS}" "${TARGET_CSS}.bak.$(date +%s)"
            # If customChrome.css is imported by existing theme, append to customChrome.css as well
            if grep -Fq "customChrome.css" "${TARGET_CSS}"; then
                echo "${GUNDAM_FIREFOX_CSS}" >> "${CUSTOM_CSS}"
                log_ok "Gundam Celestial CSS appended to ${CUSTOM_CSS}."
            fi
            echo "${GUNDAM_FIREFOX_CSS}" >> "${TARGET_CSS}"
        fi
    else
        echo "${GUNDAM_FIREFOX_CSS}" > "${TARGET_CSS}"
    fi

    log_ok "Gundam Celestial styling deployed to ${TARGET_CSS}."
done

log_ok "Firefox macOS & Gundam Celestial styling successfully configured."
