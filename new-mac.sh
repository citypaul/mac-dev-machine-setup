#!/usr/bin/env zsh

set -e

# Ensure necessary directories exist
mkdir -p ~/.ssh ~/.gnupg

# Install Xcode Command Line Tools
echo "Installing Xcode Command Line Tools..."
xcode-select --install || true

# Wait until Xcode Command Line Tools are installed
until xcode-select -p &>/dev/null; do
  echo "Waiting for Xcode Command Line Tools to be installed..."
  sleep 5
done

# Function to handle errors
handle_error() {
  echo "Error: $1"
  exit 1
}

# Check if Homebrew is installed, and install it if not
if ! command -v brew &>/dev/null; then
  echo "Homebrew not found. Installing Homebrew..."
  HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
  
  # Download and verify the script
  echo "Downloading Homebrew install script..."
  TEMP_SCRIPT=$(mktemp)
  curl -fsSL "${HOMEBREW_INSTALL_URL}" -o "${TEMP_SCRIPT}" || handle_error "Failed to download Homebrew install script"
  
  # Check if the script looks legitimate (basic validation)
  if ! grep -q "Homebrew" "${TEMP_SCRIPT}"; then
    rm -f "${TEMP_SCRIPT}"
    handle_error "Downloaded script does not appear to be the Homebrew installer"
  fi
  
  # Run the installer
  /bin/bash "${TEMP_SCRIPT}" || handle_error "Homebrew installation failed"
  rm -f "${TEMP_SCRIPT}"

  # Check if Homebrew is already in PATH
  if ! grep -q '/opt/homebrew/bin/brew shellenv' ~/.zshrc; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zshrc
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # Ensure Homebrew is in the PATH
  if ! command -v brew &>/dev/null; then
    handle_error "Homebrew installation succeeded but it's not in the PATH. Please restart your terminal and run the script again."
  fi
else
  echo "Homebrew is already installed."
fi

echo "Updating and upgrading Homebrew..."
brew update && brew upgrade || handle_error "Homebrew upgrade failed"

# Function to add Python to PATH
add_python_to_path() {
  local python_path="/opt/homebrew/opt/python@3.11/libexec/bin"
  if ! echo $PATH | grep -q $python_path; then
    export PATH="$python_path:$PATH"
  fi
  if ! grep -q "export PATH=\"$python_path:\$PATH\"" ~/.zshrc; then
    echo "export PATH=\"$python_path:\$PATH\"" >>~/.zshrc
  fi
}

# Function to install or upgrade Python
install_or_upgrade_python() {
  echo "Installing or upgrading Python..."
  brew install python || brew upgrade python || handle_error "Python installation/upgrade failed"
  add_python_to_path
  source ~/.zshrc
}

# Check if python3 is installed and working correctly
if ! command -v python3 &>/dev/null; then
  install_or_upgrade_python
fi

# Verify Python installation
if ! command -v python3 &>/dev/null; then
  handle_error "Python 3 installation failed. Please check your system and try again."
fi

# Setup python environment
python3 -m venv ~/.venv
source ~/.venv/bin/activate

# Ensure python environment is in PATH
if ! echo $PATH | grep -q "$HOME/.venv/bin"; then
  export PATH="$HOME/.venv/bin:$PATH"
  echo 'export PATH="$HOME/.venv/bin:$PATH"' >>~/.zshrc
fi

# Install Ansible
brew install ansible

# Ensure the user's local bin directory is in PATH
if ! echo $PATH | grep -q "$HOME/.local/bin"; then
  export PATH="$HOME/.local/bin:$PATH"
  echo 'export PATH="$HOME/.local/bin:$PATH"' >>~/.zshrc
fi

# Verify Ansible installation
if ! command -v ansible &>/dev/null; then
  handle_error "Ansible installation succeeded but it's not in the PATH. Please restart your terminal and run the script again."
fi
