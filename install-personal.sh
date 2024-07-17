#!/bin/zsh

# Enable verbose output
set -x

# Ensure this script runs in zsh
if [ -n "$BASH_VERSION" ]; then
    exec /bin/zsh "$0" "$@"
fi

# Print current shell and environment
echo "Current shell: $SHELL"
echo "Current PATH: $PATH"

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

# Print updated PATH
echo "Updated PATH: $PATH"

# Check if ansible-playbook is available
if ! command -v ansible-playbook &> /dev/null; then
    echo "Error: ansible-playbook command not found"
    echo "Current PATH: $PATH"
    exit 1
fi

# Run the Ansible playbook
zsh -c 'ansible-playbook local.yaml -K --tags install,personal -vvv' || {
  echo "Failed to execute Ansible playbook"
  exit 1
}

# Disable verbose output
set +x
