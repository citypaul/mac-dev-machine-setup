# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an Ansible-based Mac development machine setup automation tool that configures a fresh Mac installation with tools, applications, security settings, and system preferences. The repository follows a personal/work dual-setup pattern using 1Password as the SSH agent.

## Key Architecture

### Execution Flow

1. `install.sh` - Bootstrap script that:
   - Installs/updates Homebrew
   - Installs/updates Ansible
   - Installs required Ansible dependencies (elliotweiser.osx-command-line-tools role, community.general collection)
   - Runs the main playbook with sudo privileges (`ansible-playbook local.yaml -K`)

2. `local.yaml` - Main playbook that orchestrates all tasks in this order:
   - Prompts for machine type (personal/work) - affects SSH key selection
   - Updates Homebrew
   - Executes task files in sequence:
     - security (1Password, SSH setup)
     - git-setup (global git config)
     - cli-tools (Homebrew formulae)
     - gui-tools (Homebrew casks)
     - zsh (shell configuration)
     - app-store-apps (Mac App Store apps via `mas`)
     - osx (macOS system preferences via `defaults`)
     - node (nvm, Node LTS, GitHub Copilot CLI)
     - dotfiles (clones and stows from github.com/mintuz/.dotfiles)
     - dock (configures Dock apps and layout with dockutil)

### Critical Assumptions

1. **1Password SSH Agent**: Must be pre-installed and configured as SSH agent before running playbook
2. **Dual GitHub Identity**: Uses separate SSH keys for personal (`personal_github.pub`) and work (`work_github.pub`) stored in `.ssh/` directory and 1Password
3. **Mac App Store**: User must be logged in for `mas` to install apps
4. **Dotfiles Dependency**: Relies on external dotfiles repo (github.com/mintuz/.dotfiles) with its own install script

### Task Files Organization

All task files live in `ansible/tasks/` and use Ansible modules:
- `community.general.homebrew` - CLI tool installation
- `community.general.homebrew_cask` - GUI app installation
- `community.general.mas` - Mac App Store apps (by numeric ID)
- `git_config` - Git global configuration
- `osx_defaults` / `shell: defaults write` - macOS system preferences
- `ansible.builtin.template` - Config file templating from `ansible/templates/`

## Common Commands

### Full Setup (Fresh Mac)
```bash
./install.sh
# Will prompt for brew/ansible updates (y/N)
# Will prompt for machine type (personal/work)
# Will prompt for sudo password (-K flag)
```

### Run Specific Task Tags
```bash
# Only install CLI tools
ansible-playbook local.yaml -K --tags "cli"

# Only configure git
ansible-playbook local.yaml -K --tags "git-personal"

# Only install App Store apps
ansible-playbook local.yaml -K --tags "app-store"

# Only configure macOS settings
ansible-playbook local.yaml -K --tags "osx"

# Only setup dock
ansible-playbook local.yaml -K --tags "dock"

# SSH and security setup
ansible-playbook local.yaml -K --tags "ssh,security"
```

### Update Existing Installation
```bash
./install.sh
# Answer 'y' to update brew, ansible, and ansible extensions
# Re-runs full playbook (idempotent, but re-prompts for machine type)
```

### Test Playbook Syntax
```bash
ansible-playbook local.yaml --syntax-check
```

## Adding New Software

### CLI Tools
Add to `ansible/tasks/cli-tools.yaml` under the appropriate comment category (Core Tools, Development Tools, etc.)

### GUI Applications
Add to `ansible/tasks/gui-tools.yaml` under the appropriate comment category (Mac Utilities, Software Development, etc.)

### Mac App Store Apps
1. Find app ID: `mas search "App Name"` or check existing MAS account purchases
2. Add to `ansible/tasks/app-store-apps.yaml` following the existing pattern with proper category comments

### System Preferences
Add `defaults write` commands to `ansible/tasks/osx.yaml` - see https://macos-defaults.com for reference

### Dock Applications
Add to `ansible/tasks/dock.yaml` in the `Setup dock` task's `with_items` list
- Use full path: `/Applications/AppName.app`
- Add spacers: `"'' --type spacer --section apps --after PreviousApp"`

## Notes

- All task files use `ignore_errors: yes` to prevent single failures from blocking entire setup
- Variables `work_public_ssh_key` and `personal_public_ssh_key` are defined in `local.yaml` vars section
- SSH config template is at `ansible/templates/ssh_config.j2`
- Global gitignore template is at `ansible/templates/.global_gitignore`
- The playbook configures git for "Adam Bulmer <mintuz1990@gmail.com>" (personal setup)
- Dock setup references some apps that may not exist in gui-tools.yaml (e.g., Home.app, Arc.app, Vivaldi.app)
