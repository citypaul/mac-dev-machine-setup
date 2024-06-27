#!/bin/bash

echo -n "Would you like to update brew, ansible and ansible extensions to the latest versions? [y/N]: "
read -r update_choice

# Function to update PATH and reload shell configuration
update_path_and_reload() {
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.bash_profile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    source ~/.zprofile
    source ~/.bash_profile
}

# Check if Homebrew is installed, and install it if not
if ! command -v brew &>/dev/null; then
    HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    /bin/bash -c "$(curl -fsSL ${HOMEBREW_INSTALL_URL})" || {
        echo "Homebrew installation failed"
        exit 1
    }
    update_path_and_reload
elif [[ "$update_choice" =~ ^[Yy]$ ]]; then
    brew update && brew upgrade || {
        echo "Homebrew upgrade failed"
        exit 1
    }
fi

# Ensure Homebrew is in PATH
if ! command -v brew &>/dev/null; then
    echo "Homebrew is not in PATH. Updating PATH..."
    update_path_and_reload
fi

# Check if python3 is installed, and install it if not
if ! command -v python3 &>/dev/null; then
    echo "Installing python3..."
    brew install python3 || {
        echo "python3 installation failed"
        exit 1
    }
elif [[ "$update_choice" =~ ^[Yy]$ ]]; then
    brew upgrade python3 || {
        echo "python3 upgrade failed"
        exit 1
    }
fi

# Check if pipx is installed, and install it if not
if ! command -v pipx &>/dev/null; then
    echo "Installing pipx..."
    brew install pipx || {
        echo "pipx installation failed"
        exit 1
    }
    pipx ensurepath
    source ~/.zprofile
elif [[ "$update_choice" =~ ^[Yy]$ ]]; then
    brew upgrade pipx || {
        echo "pipx upgrade failed"
        exit 1
    }
fi

# Check if Ansible is installed, and install it if not
if ! command -v ansible &>/dev/null; then
    echo "Installing Ansible..."
    pipx install ansible --include-deps || {
        echo "Ansible installation failed"
        exit 1
    }
    pipx ensurepath
    source ~/.zprofile
elif [[ "$update_choice" =~ ^[Yy]$ ]]; then
    pipx upgrade ansible || {
        echo "Ansible upgrade failed"
        exit 1
    }
fi

# Install required Ansible roles and collections
echo "Installing Ansible roles and collections..."
ansible-galaxy install ${update_choice:+--force} elliotweiser.osx-command-line-tools || {
    echo "Failed to install or upgrade elliotweiser.osx-command-line-tools role"
    exit 1
}

ansible-galaxy collection install ${update_choice:+--force} community.general || {
    echo "Failed to install or upgrade community.general collection"
    exit 1
}

echo "Setup complete. Please restart your terminal or run 'source ~/.zprofile' to apply all changes."
