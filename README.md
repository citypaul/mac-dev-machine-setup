# Mac Dev Machine Setup

Automated setup and maintenance for macOS development environments using Ansible. This repository helps you quickly set up a new Mac or keep your existing setup up-to-date with a single command.

## Features

- 🚀 **One-command setup** for new Macs
- 🔄 **Automated updates** for all installed packages
- 🎯 **Separate profiles** for personal and work environments
- 🔐 **Secure handling** of API keys and private keys
- ✅ **Idempotent operations** - run safely multiple times
- 🛡️ **Pre-flight validation** and backup of existing configs
- 📦 **Comprehensive toolset** including modern AI tools

## Quick Start

### New Mac Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/mac-dev-setup.git
   cd mac-dev-setup
   ```

2. Run the bootstrap script:
   ```bash
   ./new-mac.sh
   ```

3. Install everything:
   ```bash
   make        # For personal setup
   # OR
   make work   # For work setup
   ```

### Existing Mac Updates

Update all installed packages:
```bash
make update
```

## Available Commands

| Command | Description |
|---------|-------------|
| `make` | Complete personal setup (all tools + personal apps) |
| `make work` | Complete work setup (essential tools only) |
| `make update` | Update all installed packages |
| `make check` | Dry run to preview changes |
| `make cli` | Install command-line tools only |
| `make gui` | Install GUI applications only |
| `make osx` | Configure macOS system preferences |
| `make dock` | Configure dock items |
| `make dotfiles` | Sync dotfiles from repository |
| `make fonts` | Install developer fonts |
| `make themes` | Install terminal themes |
| `make app-store` | Install Mac App Store apps |
| `make keys` | Install private keys (requires vault password) |

## What Gets Installed

### Development Tools
- **Languages**: Node.js (via nvm), Go, Rust, Python, Deno
- **Package Managers**: Homebrew, npm, pnpm, yarn, cargo
- **Version Control**: Git, GitHub CLI, Sourcetree
- **Containers**: Docker, Colima, lazydocker
- **Databases**: PostgreSQL tools, Redis tools, TablePlus

### Terminal & Productivity
- **Terminals**: iTerm2, Alacritty, Ghostty, WezTerm
- **Shells**: Zsh with Oh My Zsh, Starship prompt
- **Multiplexers**: tmux, Zellij
- **Editors**: Neovim, VS Code, Cursor
- **CLI Tools**: fzf, ripgrep, bat, eza, zoxide, and more

### AI & Modern Tools
- **AI Assistants**: ChatGPT, Claude, Fabric AI
- **AI Development**: Ollama for local LLMs
- **API Testing**: Bruno, Postman, HTTPie

### System Enhancements
- **Window Management**: Karabiner Elements
- **System Monitoring**: Stats, glances, htop
- **Security**: GPG tools, SSH key management
- **Productivity**: Raycast, Obsidian, Fantastical

## Customization

### Modifying Package Lists

Edit `defaults.yaml` to customize which packages get installed:

```yaml
cli_packages:
  - your-favorite-cli-tool

gui_packages:
  - your-favorite-app

gui_packages_personal:  # Only installed with 'make'
  - personal-only-app

gui_packages_work:      # Only installed with 'make work'
  - work-only-app
```

### Using Your Own Dotfiles

Update the `dotfiles_repo` in `defaults.yaml`:

```yaml
dotfiles_repo: https://github.com/yourusername/dotfiles.git
```

### API Keys and Secrets

Sensitive data is stored encrypted using Ansible Vault:

1. Create your vault file:
   ```bash
   cp vars/api_keys.yml.example vars/api_keys.yml
   ansible-vault encrypt vars/api_keys.yml
   ```

2. Edit the vault:
   ```bash
   ansible-vault edit vars/api_keys.yml
   ```

3. Install keys:
   ```bash
   make keys
   ```

## Validation and Safety

The setup includes several safety features:

- **Pre-flight checks**: Validates system requirements before running
- **Backup creation**: Backs up existing SSH/GPG keys before modification
- **Disk space check**: Warns if disk space is low
- **Internet connectivity**: Verifies connection before downloading
- **Dry run mode**: Preview changes with `make check`

## Troubleshooting

### Common Issues

1. **"Homebrew not found" after new-mac.sh**
   - Restart your terminal or run: `source ~/.zshrc`

2. **"Permission denied" errors**
   - The makefile will prompt for sudo password when needed
   - Some operations require admin access

3. **App Store apps fail to install**
   - Ensure you're signed into the Mac App Store
   - Run `mas signin your-apple-id@example.com` first

4. **Ansible Galaxy certificate errors**
   - We've removed the insecure `ignore_certs` setting
   - If you have certificate issues, fix your system certificates

### Logs and Debugging

- Run with verbose output: `ansible-playbook local.yaml -vvv`
- Check specific task: `make cli` or `make gui`
- Validate syntax: `ansible-playbook local.yaml --syntax-check`

## File Structure

```
.
├── makefile              # Main interface for all commands
├── new-mac.sh           # Bootstrap script for fresh installs
├── defaults.yaml        # Package lists and configuration
├── local.yaml           # Main Ansible playbook
├── update.yaml          # Update playbook
├── ansible/
│   ├── tasks/          # Individual task files
│   └── templates/      # Configuration templates
└── vars/
    └── api_keys.yml    # Encrypted secrets (create this)
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes with `make check`
4. Submit a pull request

## Requirements

- macOS (tested on macOS 15.0 arm64)
- Internet connection
- Apple ID (for App Store apps)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

This setup is inspired by various dotfiles repositories and automation scripts from the developer community.