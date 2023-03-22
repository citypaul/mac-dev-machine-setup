#!/bin/zsh

if ! command -v brew &>/dev/null; then
    /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "eval $(/opt/homebrew/bin/brew shellenv)" >>~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! command -v ansible &>/dev/null; then
    brew install ansible
fi

ansible-galaxy install elliotweiser.osx-command-line-tools
ansible-galaxy collection install community.general
ansible-playbook local.yaml -K
