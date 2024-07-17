#!/usr/bin/env zsh

if [ ! -f personal-keys.yaml ]; then
    echo "Error: personal-keys.yaml file not found"
    exit 1
fi

ansible-playbook personal-keys.yaml -K --ask-vault-pass --verbose || {
    echo "Failed to execute Ansible playbook for personal keys"
    exit 1
}
