# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an Ansible-based automation repository for setting up and maintaining Mac development environments. It provides automated installation and configuration of development tools, applications, and system settings for both personal and work setups.

## Common Development Commands

### Full Setup Commands

- `make` or `make all` - Complete personal setup (runs setup → deps → permissions → install → personal)
- `make work` - Complete work setup (runs setup → deps → permissions → install → work)
- `make update` - Update all installed packages (brew, npm, rust, go, etc.)
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
- Maintenance: `remove-unwanted-packages.yaml`, `dotfiles.yaml`, `update.yaml`
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
- `Brewfile.common` - Shared aggregate used for full common inventory checks
- `Brewfile.personal` - Personal-only GUI apps
- `Brewfile.work` - Work-only overlay, currently empty

`defaults.yaml` still contains non-package settings plus removal lists used by `remove-unwanted-packages.yaml`.

### Idempotency

All tasks are designed to be idempotent - they can be run multiple times safely without causing issues.

### Error Handling

Tasks include error handling and often have `ignore_errors: true` for non-critical operations that might fail on some systems.

## Known Gotchas

- **macOS TCC permissions cannot be scripted.** App Management and Automation grants require a user click (or MDM enrollment) by OS design. The repo's answer is `scripts/ensure-mac-permissions.sh`: probe, trigger the prompt, wait for the one-time grant. Never attempt to write to the TCC database or suggest disabling SIP.
- **Cask upgrades fail with "already an App at …" when install receipts are empty.** Some Homebrew versions wrote `{}` receipts, so brew forgets the old app's artifacts. `scripts/fix-cask-receipts.py` repairs them without re-downloading. See README Troubleshooting.
- **A `com.apple.macl` xattr on an app bundle blocks all xattr writes by other processes** (quarantine release fails even with App Management granted). Fix is `brew reinstall --cask <name>` for a fresh bundle.
- **`auto_updates` casks (e.g. dropbox) can be newer on disk than their brew receipt says.** `brew outdated --greedy` reads the actual bundle version, so a stale receipt alone doesn't mean an upgrade will run.
- **Casks from third-party taps need `brew trust <tap>`** (Homebrew 6+) before brew will operate on them.

## External Dependencies

- Dotfiles repository: Configured in `defaults.yaml` as `dotfiles_repo`
- Homebrew: Primary package manager for macOS
- Mac App Store CLI (`mas`): For App Store installations
- Python & pip: For Ansible and Python packages
