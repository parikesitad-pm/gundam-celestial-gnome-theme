# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-09-11

### Added
- High-speed ZRAM memory engine configured via `zram-generator` with `zram-size = ram`, `zstd` compression, and kernel memory tuning (`vm.swappiness = 180`, `vm.page-cluster = 0`).
- Floating Dash to Dock profile configured with static flat RGBA transparency (`background-opacity = 0.45`, `transparency-mode = 'FIXED'`), 48px icons, and overview collision fix (`hide-in-overview = true`).
- Top-left Celestial Being Logo Menu extension integration using `assets/img/logo/cb.png` (22px) replacing the stock Activities button with macOS system controls.
- Lean top bar Resource Monitor extension display adjacent to clock, strictly isolated to CPU and RAM usage at 3000ms polling.
- System-wide macOS window controls with left-aligned buttons (`close,minimize,maximize:`) and circular traffic lights for GTK3 and GTK4/Libadwaita applications.
- Automated fetching, extraction, and registration of MacOS Tahoe cursor theme locked to 24px size.
- Developer typography deployment utilizing JetBrains Mono font for interface, document, and monospace schemas.
- Desktop state backup and rollback engine automatically creating timestamped snapshots in `~/.config/` with `--restore` recovery and `--dry-run` simulation flags.
- Declarative preset management system (`scripts/preset-manager.sh`) featuring atomic import/export and dynamic `@REPO_DIR@` tokenization with default `gundam-00` preset.
- Ulauncher Spotlight-style launcher shortcut binding mapped to `Ctrl + Space`.
- Turnkey CLI installation loader with animated braille spinner progress indicators and quiet file logging to `/tmp/gundam-theme-install.log`.
