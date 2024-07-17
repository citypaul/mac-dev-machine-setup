#!/usr/bin/env zsh

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is not installed. Installing..."
    # Use the built-in Python to download and run get-pip.py
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python get-pip.py
    rm get-pip.py
    # Now use pip to install Python 3
    pip install python
fi

if ! source ./setup.sh; then
    echo "Failed to execute setup.sh"
    exit 1
fi

# Run the Ansible playbook
ansible-playbook local.yaml -K --tags install,personal || {
  echo "Failed to execute Ansible playbook"
  exit 1
}
