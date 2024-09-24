# Mac Dev Machine Setup

This repository contains Ansible playbooks and scripts to automatically set up a new Mac for development or update an existing one. It installs and configures various tools and applications, saving time and effort when setting up or maintaining a development environment.

## What This Repository Does

This repository automates the process of setting up a Mac for development. It:

1. Installs essential command-line tools and applications
2. Configures system preferences and settings
3. Sets up development environments for various programming languages
4. Installs and configures productivity tools
5. Manages dotfiles for consistent configurations across machines
6. Provides separate configurations for personal and work setups

## Prerequisites

- A Mac running macOS (tested on macOS 15.0 arm64)
- Internet connection

## Setting Up a New Mac

1. Clone this repository:

   ```sh
   git clone https://github.com/your-username/mac-dev-setup.git
   cd mac-dev-setup
   ```

2. Choose the appropriate installation target:

   - For personal setup:
     ```sh
     make
     ```
   - For work setup:
     ```sh
     make work
     ```

   These commands will automatically run the necessary setup scripts, install dependencies, and configure your system based on the chosen profile.

3. To install private keys (optional):

   ```sh
   make install-keys
   ```

   This uses Ansible Vault to decrypt and install private keys.

## Updating an Existing Mac

To update an existing Mac that was previously set up using this repository:

1. Navigate to the repository directory:

   ```sh
   cd path/to/mac-dev-setup
   ```

2. Pull the latest changes:

   ```sh
   git pull
   ```

3. Run the appropriate installation target:

   - For personal setup:
     ```sh
     make
     ```
   - For work setup:
     ```sh
     make work
     ```

## Personal vs. Work Setup

This repository supports both personal and work setups:

- Personal setup (`make`):

  - Installs a wider range of applications and tools
  - Configures personal Git settings
  - Sets up personal SSH and GPG keys

- Work setup (`make work`):
  - Installs a more focused set of work-related tools
  - Avoids installing personal applications
  - Can be customized further for specific work environments

## Configuration

- `defaults.yaml`: Contains default settings and package lists
- `local.yaml`: Main Ansible playbook that imports various tasks
- `vars/api_keys.yml`: Contains encrypted API keys (see [API Keys Documentation](./docs/api-keys.md))

## Post-Installation Steps

1. Set up the iTerm2 theme:

   - Open iTerm2 -> Preferences -> Profiles
   - Select "Mac Dev Environment" profile
   - Click "Other Actions" and select "Set as Default"

2. Set up GPG for Git:
   After running the installation script, manually run:
   ```sh
   gpgconf --kill gpg-agent
   ```
   Then make a Git commit to store the GPG key in the keychain.

## Screenshots

### Alacritty Terminal with Zellij

![alacritty theme](./docs/screenshots/alacritty-zellij.png)

### iTerm2 Theme

![iterm theme](./docs/screenshots/iterm-theme-example.png)

### Tmux Theme

![tmux theme](./docs/screenshots/tmux-theme-example.png)

## Disclaimer

This repository is provided as-is, without any warranties or guarantees. Always review scripts and playbooks before running them on your system, especially when they involve system-wide changes or require sudo access.
