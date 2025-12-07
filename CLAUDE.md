# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an Ansible-based automation repository for setting up and maintaining Mac development environments. It provides automated installation and configuration of development tools, applications, and system settings for both personal and work setups.

## Common Development Commands

### Full Setup Commands

- `make` or `make all` - Complete personal setup (runs setup → deps → install → personal)
- `make work` - Complete work setup (runs setup → deps → install → work)
- `make update` - Update all installed packages (brew, npm, rust, go, etc.)
- `make check` - Dry run to preview what changes would be made

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

### Running Specific Tasks

To run individual Ansible tasks with specific tags:

```bash
ansible-playbook local.yaml -K --tags <tag_name>
```

### Testing Changes

To check what changes would be made without applying them:

```bash
ansible-playbook local.yaml -K --check --diff
```

## Architecture & Key Components

### Entry Points

- `new-mac.sh` - Initial setup script for fresh Mac installations (installs Xcode tools, Homebrew, Python, Ansible)
- `makefile` - Primary interface for ALL setup tasks (use `make work` for work setup)

### Core Configuration

- `defaults.yaml` - Central configuration file containing all package lists and default settings
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
- Security: `security.yaml`, `ssh.yaml`
- System config: `osx.yaml`, `dock.yaml`, `window-management.yaml`
- AI tools: `ai-tools.yaml` (Fabric AI, Ollama, etc.)
- Maintenance: `remove-unwanted-packages.yaml`, `dotfiles.yaml`, `update.yaml`
- Validation: `validation.yaml` (pre-flight checks and backups)

### Template Files

Templates in `ansible/templates/`:

- `fabric/settings.yaml` - Fabric AI configuration
- `iterm-dynamic-profile.json` - iTerm2 profile configuration

## Key Design Patterns

### Dual Profile Support

The repository supports both personal and work environments through Ansible tags:

- Tasks tagged with `install` run for both profiles
- Tasks tagged with `personal` only run for personal setup
- Tasks tagged with `work` only run for work setup

### Package Management

All packages are defined in `defaults.yaml` under:

- `cli_packages` - Command-line tools for all profiles
- `gui_packages` - GUI applications for all profiles
- `gui_packages_personal` - Personal-only GUI apps
- `gui_packages_work` - Work-only GUI apps
- `app_store_apps` - Mac App Store applications

### Idempotency

All tasks are designed to be idempotent - they can be run multiple times safely without causing issues.

### Error Handling

Tasks include error handling and often have `ignore_errors: true` for non-critical operations that might fail on some systems.

## Secrets Management

API keys and sensitive data are stored in `vars/api_keys.yml` using Ansible Vault encryption. To edit:

```bash
ansible-vault edit vars/api_keys.yml
```

## External Dependencies

- Dotfiles repository: Configured in `defaults.yaml` as `dotfiles_repo`
- Homebrew: Primary package manager for macOS
- Mac App Store CLI (`mas`): For App Store installations
- Python & pip: For Ansible and Python packages
