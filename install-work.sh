#!/usr/bin/env zsh

source ./setup.sh

# Run the Ansible playbook
ansible-playbook local.yaml -K --tags install,work || {
  echo "Failed to execute Ansible playbook"
  exit 1
}
