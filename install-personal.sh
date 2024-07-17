#!/usr/bin/env zsh

if ! source ./setup.sh; then
    echo "Failed to execute setup.sh"
    exit 1
fi

# Ensure the updated PATH is available
source ~/.zshrc

# Run the Ansible playbook
ansible-playbook local.yaml -K --tags install,personal || {
  echo "Failed to execute Ansible playbook"
  exit 1
}
