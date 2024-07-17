#!/bin/bash

if ! source ./setup.sh; then
    echo "Failed to execute setup.sh"
    exit 1
fi

# Ensure the updated PATH is available
if [ -f ~/.zshrc ]; then
    source ~/.zshrc
elif [ -f ~/.bash_profile ]; then
    source ~/.bash_profile
elif [ -f ~/.profile ]; then
    source ~/.profile
fi

# Run the Ansible playbook
ansible-playbook local.yaml -K --tags install,personal || {
  echo "Failed to execute Ansible playbook"
  exit 1
}
