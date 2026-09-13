# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an Ansible-based automation repository for setting up and maintaining Mac development environments. It provides automated installation and configuration of development tools, applications, and system settings for both personal and work setups.

## Common Development Commands

### Full Setup Commands

- `make` or `make all` - Complete personal setup (runs setup → deps → permissions → install → personal)
- `make work` - Complete work setup (runs setup → deps → permissions → install → work)
- `make update` - Install anything missing from the Brewfiles, apply the removal lists, then upgrade everything (brew, npm, rust, go, etc.). Use `make update PROFILE=work` on a work machine
- `make check` - Dry run to preview what changes would be made

All install/update targets first run `make permissions`, which verifies the terminal has the macOS TCC permissions Homebrew needs (App Management + Automation) and interactively requests them if missing — a one-time grant per machine/terminal.

### Individual Task Commands

- `make deps` - Install Ansible dependencies (required before other tasks)
- `make install` - Run core installation tasks
- `make personal` - Install personal-specific packages
- `make keys` - Install private keys (requires vault password)
- `make cli` - Install CLI tools only
- `make gui` - Install GUI applications only
- `make osx` - Configure macOS system preferences
- `make dock` - Configure dock items
- `make fonts` - Install fonts
- `make themes` - Install themes
- `make app-store` - Install Mac App Store apps
- `make dotfiles` - Sync dotfiles from external repository
- `make git` - Configure git identity, aliases, and GPG signing (runs `git-personal` tag)
- `make node` - Install Node.js tooling only
- `make permissions` - Standalone run of the macOS TCC permission pre-flight
- `make work-remove` - Remove work-only packages (runs `work-remove` tag)
- `make drift` - List installed packages no Brewfile tracks (`PROFILE=work` on a work machine)
- `make lint` - Run the CI checks: helper-script tests, yamllint, shellcheck, playbook syntax, Brewfile parsing

### Running Specific Tasks

To run individual Ansible tasks with specific tags:

```bash
scripts/with-sudo-askpass.sh ansible-playbook local.yaml --tags <tag_name>
```

### Testing Changes

To check what changes would be made without applying them:

```bash
scripts/with-sudo-askpass.sh ansible-playbook local.yaml --check --diff
```

Static checks, also run by CI (`.github/workflows/checks.yml`) on every pull request: helper-script unit tests, yamllint, shellcheck, playbook syntax and Brewfile parsing:

```bash
make lint
```

## Architecture & Key Components

### Entry Points

- `new-mac.sh` - Initial setup script for fresh Mac installations (installs Xcode tools, Homebrew, Python, Ansible)
- `makefile` - Primary interface for ALL setup tasks (use `make work` for work setup)

### Core Configuration

- `Brewfile.*` - Homebrew Bundle package inventories for CLI, GUI, App Store, and profile overlays
- `defaults.yaml` - Central configuration file for non-Brewfile settings and removal lists
- `local.yaml` - Main Ansible playbook that orchestrates all tasks (includes validation)
- `update.yaml` - Update playbook for refreshing all installed packages
- `setup.yaml` - Prerequisites installation playbook
- `personal-keys.yaml` - Encrypted private key installation (SSH)
- `ansible.cfg` - Ansible runtime configuration
- `requirements.yaml` - Ansible Galaxy dependencies

### Task Organization

All Ansible tasks are in `ansible/tasks/`:

- Development tools: `cli-tools.yaml`, `gui-tools.yaml`, `node.yaml`, `rust.yaml`
- Terminal & editors: `iterm.yaml`, `nvim.yaml`, `zsh.yaml`, `themes.yaml`, `fonts.yaml`
- Security: `ssh.yaml`, `gpg.yaml`
- System config: `osx.yaml`, `dock.yaml`
- Maintenance: `remove-unwanted-packages.yaml`, `remove-work-packages.yaml`, `dotfiles.yaml`, `update.yaml`
- Apps outside Homebrew: `talat.yaml`
- Validation: `validation.yaml` (pre-flight checks and backups)

### Template Files

Templates in `ansible/templates/`:

- `iterm-dynamic-profile.json` - iTerm2 profile configuration

### Static Files

Static files in `ansible/files/`:

- `gpg/public-keys.asc` - GPG public keys imported on fresh machines so YubiKey signing works

### Scripts

Helper scripts in `scripts/`:

- `gpg-auto-sign.sh` - GPG wrapper that auto-detects the signing key from the currently-inserted YubiKey
- `fix-cask-receipts.py` - Repairs empty Homebrew cask receipts that break `brew upgrade` with "already an App at" errors
- `clear-stale-cask-receipts.py` - Clears brew's install record for any Brewfile cask whose installed files have gone missing, so the `brew bundle` that follows reinstalls it. Runs before the GUI and personal bundles; `--dry-run` only reports. Tests: `test_clear_stale_cask_receipts.py`
- `ensure-mac-permissions.sh` - Pre-flight check that the terminal has the App Management and Automation TCC permissions Homebrew needs; triggers the one-time grant prompts if missing. Runs automatically before install/update make targets (`make permissions` to run standalone)

## Key Design Patterns

### Dual Profile Support

The repository supports both personal and work environments through Ansible tags:

- Tasks tagged with `install` run for both profiles
- Tasks tagged with `personal` only run for personal setup
- Tasks tagged with `work` only run for work setup

### Tag Relationships

Some tasks share tags so they run together:

- `git-setup.yaml` and `gpg.yaml` both have `git-personal` and `install` tags, so `make git` configures both git identity/aliases and GPG signing in a single command
- `make` and `make work` both run the `install` tag, which includes git and GPG setup

### Package Management

Homebrew-managed packages are defined in Brewfiles:

- `Brewfile.cli` - Command-line tools for all profiles
- `Brewfile.gui` - GUI applications and security casks for all profiles
- `Brewfile.app-store` - Mac App Store applications
- `Brewfile.fonts` - Fonts for all profiles
- `Brewfile.common` - Shared aggregate used for full common inventory checks
- `Brewfile.personal` - Personal-only GUI apps
- `Brewfile.work` - Work-only overlay, currently empty

`defaults.yaml` contains non-package settings plus removal lists used by `remove-unwanted-packages.yaml`.

### Brewfiles Are the Source of Truth

Every run makes the machine match the Brewfiles:

- Stale records are cleared before the GUI bundles (`clear-stale-cask-receipts.py`), so an app deleted outside Homebrew is reinstalled
- `make update` enforces the same before upgrading: clears stale records, installs anything missing (`--no-upgrade`), then runs the removal lists. `update_profile` (`PROFILE=`) picks the personal or work Brewfile
- Bundles run with `--force`, overwriting apps and files Homebrew didn't install
- Dropping a Brewfile entry does **not** uninstall it — also add it to the matching removal list in `defaults.yaml` (`cli_packages_to_remove_if_installed`, `gui_packages_to_remove_if_installed`, `app_store_apps_to_remove_if_installed`, or `gui_packages_to_zap_if_installed` to also delete the app's data)
- Apps not on Homebrew or the App Store get their own task file: `talat.yaml` installs Talat from its release feed when missing (it self-updates afterwards) and verifies notarization and the developer's Team ID before moving it into `/Applications`
- Every Homebrew package the repo installs is in a Brewfile. The `nvm`, `stow` and `dockutil` installs left in their tasks are only prerequisites so `make node`, `make dotfiles` and `make dock` work on their own
- Work-only removals live in `remove-work-packages.yaml`, imported only for the work profile. Never add them to `remove-unwanted-packages.yaml`, which `make update` runs on every machine
- Don't run `brew bundle cleanup --force` wholesale: `make drift` also lists packages installed by hand and their dependencies

### Idempotency

All tasks are designed to be idempotent - they can be run multiple times safely without causing issues.

### Error Handling

Tasks include error handling and often have `ignore_errors: true` for non-critical operations that might fail on some systems.

## Known Gotchas

- **macOS TCC permissions cannot be scripted.** App Management and Automation grants require a user click (or MDM enrollment) by OS design. The repo's answer is `scripts/ensure-mac-permissions.sh`: probe, trigger the prompt, wait for the one-time grant. Never attempt to write to the TCC database or suggest disabling SIP.
- **Cask upgrades fail with "already an App at …" when install receipts are empty.** Some Homebrew versions wrote `{}` receipts, so brew forgets the old app's artifacts. `scripts/fix-cask-receipts.py` repairs them without re-downloading. See README Troubleshooting.
- **A `com.apple.macl` xattr on an app bundle blocks all xattr writes by other processes** (quarantine release fails even with App Management granted). Fix is `brew reinstall --cask <name>` for a fresh bundle.
- **Don't manage Parallels Desktop with a cask.** It installs itself root-owned with `com.apple.macl`, so `brew bundle --force` can't replace it: brew's `sudo chown -R` fails on every file with `Operation not permitted`, even with App Management granted. It updates itself, so leave it out of the Brewfiles. Brew-installed apps that merely carry `com.apple.macl` (user-owned) install and upgrade fine.
- **`auto_updates` casks (e.g. dropbox) can be newer on disk than their brew receipt says.** `brew outdated --greedy` reads the actual bundle version, so a stale receipt alone doesn't mean an upgrade will run.
- **Casks from third-party taps need `brew trust <tap>`** (Homebrew 6+) before brew will operate on them.
- **An app deleted outside Homebrew keeps its brew record**, so `brew bundle check` reports the Brewfile satisfied and the install is skipped. `scripts/clear-stale-cask-receipts.py` clears those records; don't add per-app checks (a hard-coded app path goes stale when a cask renames its app, as SilentKnight did).
- **Homebrew deletes formulae and casks, and the homebrew Ansible modules fail on unknown names even with `state: absent`** (neofetch broke a full `make` this way). Removal tasks therefore check `brew list` and run `brew uninstall` only on installed packages, which also works when the package no longer exists in Homebrew. Don't switch them back to the modules.
- **The `community.general.mas` module crashes on mas 7's `mas list`** with `invalid literal for int() with base 10: ''`: mas right-aligns app ids, so shorter ids start with a space. App Store removals parse `mas list` themselves and run `sudo mas uninstall` only for installed ids.
- **Uninstalling a Mac App Store app needs root.** `mas uninstall` refuses otherwise, so the removal task uses `become`, which gets its password from `scripts/with-sudo-askpass.sh`.
- **`brew bundle cleanup` can't take a piped Brewfile.** `Brewfile.common` loads its parts relative to its own location, which becomes `/dev` on stdin; `make drift` writes a temporary Brewfile instead. `brew bundle cleanup` also exits 1 whenever it lists anything.

## External Dependencies

- Dotfiles repository: Configured in `defaults.yaml` as `dotfiles_repo`
- Homebrew: Primary package manager for macOS
- Mac App Store CLI (`mas`): For App Store installations
- Python & pip: For Ansible and Python packages
