# Mac Dev Machine Setup

This repository contains Ansible playbooks and scripts to automatically set up a new Mac for development. It installs and configures various tools and applications, saving time and effort when setting up a new machine.

## Prerequisites

- A Mac running macOS (tested on macOS 15.0 arm64)
- Internet connection

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/your-username/mac-dev-setup.git
   cd mac-dev-setup
   ```

2. Choose the appropriate installation script:
   - For personal setup: `./install-personal.sh`
   - For work setup: `./install-work.sh`

   These scripts will:
   - Run `setup.sh` to install or update Homebrew, Python, pipx, and Ansible
   - Execute the appropriate Ansible playbook with the necessary tags

3. To install private keys (optional):
   ```
   ./install-keys.sh
   ```
   This script uses Ansible Vault to decrypt and install private keys.

## Configuration

- The `defaults.yaml` file contains default settings and package lists.
- The `local.yaml` file is the main Ansible playbook that imports various tasks.

## Post-Installation Steps

1. Set up the iTerm2 theme:
   - Open iTerm2 -> Preferences -> Profiles
   - Select "Mac Dev Environment" profile
   - Click "Other Actions" and select "Set as Default"

   ![iterm theme instructions](./docs/screenshots/choose-iterm-theme.png)

2. Set up GPG for Git:
   After running the installation script, manually run:
   ```
   gpgconf --kill gpg-agent
   ```
   Then make a Git commit. This will store the GPG key in the keychain.

## Screenshots

### Alacritty Terminal with Zellij
![alacritty theme](./docs/screenshots/alacritty-zellij.png)

### iTerm2 Theme
![iterm theme](./docs/screenshots/iterm-theme-example.png)

### Tmux Theme
![tmux theme](./docs/screenshots/tmux-theme-example.png)

## Troubleshooting

- If you encounter issues with Python or pip, try the following steps:
  1. Ensure you have the latest version of Homebrew:
     ```
     brew update && brew upgrade
     ```
  2. Reinstall Python using Homebrew:
     ```
     brew reinstall python
     ```
  3. Install pipx if it's not already installed:
     ```
     brew install pipx
     pipx ensurepath
     ```
  4. Restart your terminal or source your `.zshrc`:
     ```
     source ~/.zshrc
     ```
- If Homebrew is installed but not recognized, restart your terminal and run the script again.
- If certain tools are not recognized after installation, try sourcing your `.zshrc` file:
  ```
  source ~/.zshrc
  ```
- In some cases, you may need to run the installation script multiple times to ensure all components are properly installed and configured.
- If you encounter permission issues, ensure you have the necessary rights to install software on your system.
- If you see an "externally-managed-environment" error, make sure you're using pipx to install Python packages as described in the setup script.

## Additional Resources

- [Understanding GPG keys in Git](https://samuelsson.dev/sign-git-commits-on-github-with-gpg-in-macos/)
- [Dotfiles Repository](https://github.com/citypaul/.dotfiles)

## Contributing

This is a personal project for my own setup, but if you find any issues or have suggestions, please feel free to open an issue or submit a pull request.

## License

[Include your license information here]
