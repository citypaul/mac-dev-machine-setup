#!/usr/bin/env zsh

echo -n "Would you like to update brew, ansible and ansible extensions to the latest versions? [y/N]: "
read update_choice

# Check if Homebrew is installed, and install it if not
if ! command -v brew &>/dev/null; then
    HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    /bin/bash -c "$(curl -fsSL ${HOMEBREW_INSTALL_URL})" || {
        echo "Homebrew installation failed"
        exit 1
    }

    echo "eval $(/opt/homebrew/bin/brew shellenv)" >>~/.zshrc
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ "$update_choice" =~ ^[Yy]$ ]]; then
    # If Homebrew is installed, upgrade to the latest version
    brew update && brew upgrade || {
        echo "Homebrew upgrade failed"
        exit 1
    }
fi

# Check if python is installed, and install it if not
if ! command -v python &>/dev/null; then
    brew install python3 || {
        echo "python installation failed"
        exit 1
    }
elif [[ "$update_choice" =~ ^[Yy]$ ]]; then
    # If python is installed, upgrade to the latest version
    brew upgrade python3 || {
        echo "python upgrade failed"
        exit 1
    }
fi

# Check if pip is installed, and install it if not
if ! command -v pip &>/dev/null; then
    curl -sSL https://bootstrap.pypa.io/get-pip.py | python3 || {
        echo "pip installation failed"
        exit 1
    }
elif [[ "$update_choice" =~ ^[Yy]$ ]]; then
    # If pip is installed, upgrade to the latest version
    pip install --upgrade pip || {
        echo "pip upgrade failed"
        exit 1
    }
fi

# Check if pipx is installed, and install it if not
if ! command -v pipx &>/dev/null; then
    pip install --user pipx || {
        echo "pipx installation failed"
        exit 1
    }
elif [[ "$update_choice" =~ ^[Yy]$ ]]; then
    # If pipx is installed, upgrade to the latest version
    pipx upgrade pipx || {
        echo "pipx upgrade failed"
        exit 1
    }
fi

(
    source "$HOME/.zshrc"
    # Check if Ansible is installed, and install it if not
    if ! command -v ansible &>/dev/null; then
        pipx install ansible --include-deps && pipx ensurepath && source "$HOME/.zshrc" || {
            echo "Ansible installation failed"
            exit 1
        }
    elif [[ "$update_choice" =~ ^[Yy]$ ]]; then
        # If Ansible is installed, upgrade to the latest version
        pipx upgrade ansible || {
            echo "Ansible upgrade failed"
            exit 1
        }
    fi

    # Install required Ansible roles and collections
    ansible-galaxy install ${update_choice:+--force} elliotweiser.osx-command-line-tools || {
        echo "Failed to install or upgrade elliotweiser.osx-command-line-tools role"
        exit 1
    }

    ansible-galaxy collection install ${update_choice:+--force} community.general || {
        echo "Failed to install or upgrade community.general collection"
        exit 1
    }

    # Run the Ansible playbook
    ansible-playbook local.yaml -K || {
        echo "Failed to execute Ansible playbook"
        exit 1
    }
)
