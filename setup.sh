#!/usr/bin/env zsh

set -e

# Ensure necessary directories exist
mkdir -p ~/.ssh ~/.gnupg

echo -n "Would you like to update brew, ansible and ansible extensions to the latest versions? [y/N]: "
read -r update_choice

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Check if Homebrew is installed, and install it if not
if ! command -v brew &>/dev/null; then
    HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    /bin/bash -c "$(curl -fsSL ${HOMEBREW_INSTALL_URL})" || handle_error "Homebrew installation failed"

    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    eval "$(/opt/homebrew/bin/brew shellenv)"

    # Ensure Homebrew is in the PATH
    if ! command -v brew &>/dev/null; then
        handle_error "Homebrew installation succeeded but it's not in the PATH. Please restart your terminal and run the script again."
    fi
elif [[ "$update_choice" =~ ^[Yy]$ ]]; then
    # If Homebrew is installed, upgrade to the latest version
    brew update && brew upgrade || handle_error "Homebrew upgrade failed"
fi

# Check if python3 is installed, and install it if not
if ! command -v python3 &>/dev/null; then
    echo "Python 3 is not installed. Installing..."
    brew install python3 || handle_error "Python installation failed"
    # Ensure python3 is in the PATH
    eval "$(/opt/homebrew/bin/brew shellenv)"
    if ! command -v python3 &>/dev/null; then
        handle_error "Python 3 installation succeeded but it's not in the PATH. Please restart your terminal and run the script again."
    fi
elif [[ "$update_choice" =~ ^[Yy]$ ]]; then
    # If python is installed, upgrade to the latest version
    brew upgrade python3 || handle_error "Python upgrade failed"
fi

# Check if pipx is installed, and install it if not
if ! command -v pipx &>/dev/null; then
    brew install pipx || handle_error "pipx installation failed"
elif [[ "$update_choice" =~ ^[Yy]$ ]]; then
    # If pipx is installed, upgrade to the latest version
    brew upgrade pipx || handle_error "pipx upgrade failed"
fi

(
    source "$HOME/.zshrc"
    # Check if Ansible is installed, and install it if not
    if ! command -v ansible &>/dev/null; then
        pipx install ansible --include-deps && pipx ensurepath && source "$HOME/.zshrc" || handle_error "Ansible installation failed"
    elif [[ "$update_choice" =~ ^[Yy]$ ]]; then
        # If Ansible is installed, upgrade to the latest version
        pipx upgrade ansible || handle_error "Ansible upgrade failed"
    fi

    # Install required Ansible roles and collections
    ansible-galaxy install ${update_choice:+--force} elliotweiser.osx-command-line-tools || handle_error "Failed to install or upgrade elliotweiser.osx-command-line-tools role"

    ansible-galaxy collection install ${update_choice:+--force} community.general || handle_error "Failed to install or upgrade community.general collection"
)
