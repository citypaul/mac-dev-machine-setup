#!/usr/bin/env bash

# Check if Homebrew is installed, and install it if not
if ! command -v brew &>/dev/null; then
    HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    /bin/bash -c "$(curl -fsSL ${HOMEBREW_INSTALL_URL})" || {
        echo "Homebrew installation failed"
        exit 1
    }

    echo "eval $(/opt/homebrew/bin/brew shellenv)" >>~/.bashrc
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

(
    source "$HOME/.bashrc"
    # Check if Ansible is installed, and install it if not
    if ! command -v ansible &>/dev/null; then
        brew install ansible || {
            echo "Ansible installation failed"
            exit 1
        }
    fi

    # Install required Ansible roles and collections
    ansible-galaxy install elliotweiser.osx-command-line-tools || {
        echo "Failed to install elliotweiser.osx-command-line-tools role"
        exit 1
    }

    ansible-galaxy collection install community.general || {
        echo "Failed to install community.general collection"
        exit 1
    }

    # Run the Ansible playbook
    ansible-playbook local.yaml -K || {
        echo "Failed to execute Ansible playbook"
        exit 1
    }
)
