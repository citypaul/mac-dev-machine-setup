#!/bin/bash

set -e

# Ensure necessary directories exist
mkdir -p ~/.ssh ~/.gnupg

# Set up the shell environment
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

echo -n "Would you like to update brew, ansible and ansible extensions to the latest versions? [y/N]: "
read -r update_choice

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Check if Homebrew is installed, and install it if not
if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    /bin/bash -c "$(curl -fsSL ${HOMEBREW_INSTALL_URL})" || handle_error "Homebrew installation failed"

    # Add Homebrew to PATH in .zshrc
    if [ -f /opt/homebrew/bin/brew ]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    elif [ -f /usr/local/bin/brew ]; then
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
    fi

    # Source .zshrc to update PATH
    source ~/.zshrc

    # Ensure Homebrew is in the PATH
    if ! command -v brew &>/dev/null; then
        handle_error "Homebrew installation succeeded but it's not in the PATH. Please restart your terminal and run the script again."
    fi
else
    echo "Homebrew is already installed."
fi

if [[ "$update_choice" =~ ^[Yy]$ ]]; then
    echo "Updating and upgrading Homebrew..."
    brew update && brew upgrade || handle_error "Homebrew upgrade failed"
fi

# Function to add Python to PATH
add_python_to_path() {
    local python_path="/opt/homebrew/opt/python@3.11/libexec/bin"
    if ! echo $PATH | grep -q $python_path; then
        export PATH="$python_path:$PATH"
    fi
    if ! grep -q "export PATH=\"$python_path:\$PATH\"" ~/.zshrc; then
        echo "export PATH=\"$python_path:\$PATH\"" >> ~/.zshrc
    fi
    source ~/.zshrc
}

# Function to install or upgrade Python
install_or_upgrade_python() {
    echo "Installing or upgrading Python..."
    brew install python || brew upgrade python || handle_error "Python installation/upgrade failed"
    add_python_to_path
    source ~/.zshrc
}

# Check if python3 is installed and working correctly
if ! command -v python3 &>/dev/null; then
    install_or_upgrade_python
fi

# Verify Python installation
if ! command -v python3 &>/dev/null; then
    handle_error "Python 3 installation failed. Please check your system and try again."
fi

# Check if pipx is installed, and install it if not
if ! command -v pipx &>/dev/null; then
    brew install pipx || handle_error "pipx installation failed"
elif [[ "$update_choice" =~ ^[Yy]$ ]]; then
    # If pipx is installed and user chose to update, upgrade to the latest version
    brew upgrade pipx || echo "pipx is already at the latest version"
else
    echo "pipx is already installed. Skipping installation/upgrade."
fi

# Ensure pipx is in PATH
eval "$(pipx ensurepath)"

# Install or upgrade Ansible using pipx
if ! command -v ansible &>/dev/null || [[ "$update_choice" =~ ^[Yy]$ ]]; then
    pipx install --include-deps ansible || pipx upgrade --include-deps ansible || handle_error "Ansible installation/upgrade failed"
fi

# Verify Ansible installation
if ! command -v ansible &>/dev/null; then
    handle_error "Ansible installation failed. Please check your system and try again."
fi

# Ensure pipx binaries are in PATH
export PATH="$HOME/.local/bin:$PATH"

# Check and update .zsh_profile
if [ -f ~/.zsh_profile ]; then
    if grep -q "/opt/homebrew/etc/profile.d/z.sh" ~/.zsh_profile; then
        sed -i '' '/\/opt\/homebrew\/etc\/profile.d\/z.sh/d' ~/.zsh_profile
        echo '[ -f /opt/homebrew/etc/profile.d/z.sh ] && source /opt/homebrew/etc/profile.d/z.sh' >> ~/.zsh_profile
    fi
fi

# Install required Ansible roles and collections
if [[ "$update_choice" =~ ^[Yy]$ ]]; then
    ansible-galaxy install --force elliotweiser.osx-command-line-tools || handle_error "Failed to install or upgrade elliotweiser.osx-command-line-tools role"
    ansible-galaxy collection install --force community.general || handle_error "Failed to install or upgrade community.general collection"
else
    ansible-galaxy install elliotweiser.osx-command-line-tools || handle_error "Failed to install elliotweiser.osx-command-line-tools role"
    ansible-galaxy collection install community.general || handle_error "Failed to install community.general collection"
fi

# Ensure Ansible binaries are in PATH
export PATH="$HOME/.local/bin:$PATH"
