#!/usr/bin/env zsh
set -euo pipefail

handle_error() {
  echo "Error: $1" >&2
  exit 1
}

install_cask_if_missing() {
  local cask="$1"
  local app_path="${2:-}"

  if brew list --cask "$cask" >/dev/null 2>&1; then
    echo "$cask is already installed."
    return
  fi

  if [[ -n "$app_path" && -e "$app_path" ]]; then
    echo "$app_path already exists; skipping Homebrew cask install for $cask."
    return
  fi

  brew install --cask "$cask" || handle_error "Failed to install $cask"
}

mkdir -p "$HOME/.ssh" "$HOME/.gnupg"

if ! xcode-select -p >/dev/null 2>&1; then
  echo "Starting Xcode Command Line Tools installer..."
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do
    echo "Waiting for Xcode Command Line Tools to finish installing..."
    sleep 5
  done
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  temp_script="$(mktemp)"
  curl -fsSL "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" -o "$temp_script" \
    || handle_error "Failed to download Homebrew installer"
  grep -q "Homebrew" "$temp_script" || handle_error "Downloaded script does not look like Homebrew"
  /bin/bash "$temp_script" || handle_error "Homebrew installation failed"
  rm -f "$temp_script"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  if ! grep -q '/opt/homebrew/bin/brew shellenv' "$HOME/.zshrc" 2>/dev/null; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zshrc"
  fi
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  if ! grep -q '/usr/local/bin/brew shellenv' "$HOME/.zshrc" 2>/dev/null; then
    echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zshrc"
  fi
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew update || handle_error "Homebrew update failed"
install_cask_if_missing 1password "/Applications/1Password.app"
install_cask_if_missing 1password-cli
brew install ansible || brew upgrade ansible || handle_error "Ansible installation failed"
ansible-galaxy collection install -f -r requirements.yaml || handle_error "Ansible collection installation failed"

echo "Bootstrap complete. Configure 1Password as your SSH agent, then run 'make' for a personal machine or 'make work' for a work machine."
