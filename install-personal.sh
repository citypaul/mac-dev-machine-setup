#!/bin/zsh

# Ensure this script runs in zsh
if [ -n "$BASH_VERSION" ]; then
    exec /bin/zsh "$0" "$@"
fi

if ! zsh ./setup.sh; then
    echo "Failed to execute setup.sh"
    exit 1
fi

# Ensure the updated PATH is available
if [ -f ~/.zshrc ]; then
    source ~/.zshrc
else
    echo "Warning: ~/.zshrc not found. Make sure zsh is properly set up."
fi

# Run the Ansible playbook
zsh -c 'ansible-playbook local.yaml -K --tags install,personal' || {
  echo "Failed to execute Ansible playbook"
  exit 1
}
