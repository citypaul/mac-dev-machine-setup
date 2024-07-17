#!/usr/bin/env zsh

ansible-playbook personal-keys.yaml -K --ask-vault-pass --verbose || {
    echo "Failed to execute Ansible playbook for personal keys"
    exit 1
}
