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
| `make git` | Configure git identity, aliases, and GPG signing |
| `make fonts` | Install developer fonts |
| `make themes` | Install terminal themes |
| `make app-store` | Install Mac App Store apps |
| `make keys` | Install private keys (requires vault password) |
| `make gpg` | Configure GPG signing for git (auto-detects key) |
| `make gpg-setup` | Interactive YubiKey GPG key setup wizard |

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
- **Security**: SSH key management, GPG signing with YubiKey
- **Productivity**: Raycast, Obsidian, Fantastical

## Git Configuration

The setup includes comprehensive Git configuration with productivity-enhancing aliases and modern diff tools.

### Git Settings

The following Git configurations are automatically applied:

- **Editor**: Neovim as default editor
- **Pull strategy**: Rebase by default
- **Auto-prune**: Fetch automatically prunes deleted remote branches
- **Auto-setup remote**: Automatically sets upstream on push
- **Default branch**: `main` for new repositories
- **Diff tool**: Difftastic for syntax-aware diffs

### Git Aliases

#### Basic Commands
- `git co` - checkout
- `git br` - branch
- `git ci` - commit
- `git st` - status
- `git last` - show last commit
- `git unstage` - unstage files
- `git lg` - compact log with graph

#### Difftastic Integration
- `git dlog` - log with difftastic diffs
- `git dshow` - show commit with difftastic
- `git ddiff` - diff with difftastic
- `git dl` - log with patches using difftastic
- `git ds` - short alias for dshow
- `git dft` - short alias for ddiff

#### Productivity Aliases
- `git amend` - amend last commit without editing message
- `git undo` - undo last commit, keeping changes
- `git wip` - quick work-in-progress commit
- `git cleanup [N]` - interactive rebase last N commits (default: 10)
- `git fixup <commit>` - create fixup commit
- `git recent` - show recently worked branches
- `git aliases` - list all configured aliases

#### Branch Management
- `git branches` - show all branches with tracking info
- `git gone` - list branches whose remotes are gone
- `git prune-branches` - delete branches whose remotes are gone
- `git main` - checkout the main/master branch

#### Stash Improvements
- `git stash-all` - stash including untracked files
- `git pop` - pop latest stash

#### History Exploration
- `git contributors` - show contributor statistics
- `git graph` - pretty graph of commit history
- `git today` - show your commits from today
- `git yesterday` - show your commits from yesterday

#### File Operations
- `git untrack <file>` - stop tracking file
- `git ignored` - show ignored files
- `git modified` - list modified files only

#### Search and Blame
- `git find <text>` - search commit messages
- `git who <file>` - enhanced blame with move/copy detection

### FZF-Powered Interactive Git Commands

These aliases provide an interactive interface using fzf (fuzzy finder) with live previews, making git operations more visual and intuitive.

#### Interactive Checkout & Navigation
- `git fco` - **Fuzzy checkout branch** - Search and checkout any branch (local or remote) with commit preview
- `git fcoc` - **Checkout any commit** - Browse entire commit history and checkout with preview
- `git fbr` - **Branch switcher** - Switch between local branches with commit history preview
- `git ftag` - **Tag browser** - Browse and checkout tags with full diff preview

#### Interactive File Operations
- `git fadd` - **Stage files interactively** - Select files to stage with diff preview (supports multi-select with TAB)
- `git funstage` - **Unstage files** - Select staged files to unstage with preview
- `git fdiff` - **Diff browser** - Select modified files to diff interactively

#### Interactive Commit Operations
- `git fshow` - **Commit browser** - Browse commits and show details with full diff preview
- `git flog` - **Log explorer** - Browse and select multiple commits (returns commit SHAs)
- `git fcherry` - **Cherry-pick commits** - Select commits to cherry-pick with preview (multi-select with TAB)
- `git ffix` - **Create fixup commits** - Select target commit for fixup with preview
- `git frebase` - **Interactive rebase from point** - Select commit to start interactive rebase from

#### Interactive Stash & Branch Management
- `git fstash` - **Stash browser** - Browse stashes with full diff preview and apply selected
- `git fbrm` - **Delete branches** - Select branches to delete (supports multi-select with TAB)

#### Interactive Search
- `git fgrep [pattern]` - **Grep in tracked files** - Select file to search with bat preview, then grep for pattern

**Tips for FZF aliases:**
- Use `TAB` to multi-select items where supported
- Use `Ctrl-C` or `ESC` to cancel without making changes
- Type to fuzzy search through the list
- Arrow keys or `Ctrl-J/K` to navigate
- `Enter` to confirm selection

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

### GPG Signing with YubiKey

This setup supports signing git commits with a GPG key stored on a YubiKey for enhanced security. **Multiple YubiKeys with different keys are supported** - git automatically detects which YubiKey is currently inserted and uses the correct key.

#### Prerequisites

- YubiKey with OpenPGP support (YubiKey 5 series recommended)
- GPG and YubiKey tools (installed automatically via `make cli`)

#### How It Works

GPG signing is automatically configured when you run `make git` (or `make` / `make work`, which include it). The setup:

1. **Imports GPG public keys** from `ansible/files/gpg/public-keys.asc` into your local keyring (required for GPG to sign with YubiKey-stored private keys)
2. **Detects the signing key** from the currently-inserted YubiKey (tries keyring first, falls back to parsing `gpg --card-status` fingerprint)
3. **Configures git** with the detected key, enables commit signing, and installs the `gpg-auto-sign` wrapper script

#### First-Time Setup

1. **Install prerequisites:**
   ```bash
   make cli
   ```
   This installs `gnupg`, `pinentry-mac`, and `ykman`.

2. **Set up your GPG key on YubiKey** (if not already done):
   ```bash
   make gpg-setup
   ```
   This interactive wizard will:
   - Check if your YubiKey is connected
   - Detect existing GPG keys on the YubiKey
   - Guide you through generating a new key or importing an existing one

3. **Export your public key and add it to this repo:**
   ```bash
   gpg --armor --export YOUR_KEY_ID >> ansible/files/gpg/public-keys.asc
   ```
   This ensures fresh machines can import the public key before configuring signing.

4. **Configure git to sign commits:**
   ```bash
   make git
   ```
   This automatically:
   - Imports stored public keys into the local GPG keyring
   - Detects your GPG key ID from the inserted YubiKey
   - Configures git to use it for signing
   - Enables commit signing by default

5. **Add your public key to GitHub:**
   ```bash
   gpg --armor --export YOUR_KEY_ID
   ```
   Copy the output and add it at: https://github.com/settings/keys

#### Daily Usage

After setup, git commits are automatically signed. The 8-hour cache means you'll enter your YubiKey PIN once per workday.

```bash
# Test signing works
git commit --allow-empty -m "Test signed commit"
git log --show-signature -1

# Verify YubiKey is detected
gpg --card-status
```

#### Backup YubiKey Setup

**Important:** Keys generated directly on a YubiKey cannot be extracted. Plan for backup BEFORE generating keys.

##### Option 1: Off-Card Backup During Generation (Recommended)

When running `make gpg-setup` and choosing to generate a new key:
1. When asked "Make off-card backup of encryption key?", choose **Yes**
2. GPG will create an encrypted backup file in `~/.gnupg/`
3. Store this backup securely (encrypted USB, password manager, safe)

To restore to a backup YubiKey:
```bash
# Import the backup key
gpg --import ~/.gnupg/sk_XXXXX.gpg

# Insert backup YubiKey
# Move the key to the new YubiKey
gpg --edit-key YOUR_KEY_ID
keytocard
# Select slot 1 for Signature, 2 for Encryption, 3 for Authentication
save
```

##### Option 2: Generate Keys on Computer First

For maximum flexibility with multiple YubiKeys:

```bash
# 1. Generate a master key on your computer (NOT on YubiKey)
gpg --full-generate-key
# Choose RSA (sign only), 4096 bits, set expiration

# 2. Add subkeys for signing, encryption, authentication
gpg --edit-key YOUR_KEY_ID
addkey  # Add signing subkey
addkey  # Add encryption subkey
addkey  # Add authentication subkey
save

# 3. Export backup BEFORE moving to YubiKey
gpg --armor --export-secret-keys YOUR_KEY_ID > master-key-backup.asc
gpg --armor --export-secret-subkeys YOUR_KEY_ID > subkeys-backup.asc
# Store these securely!

# 4. Move subkeys to primary YubiKey
gpg --edit-key YOUR_KEY_ID
key 1  # Select first subkey
keytocard
key 1  # Deselect
key 2  # Select second subkey
keytocard
# Repeat for all subkeys
save

# 5. For backup YubiKey, reimport and repeat
gpg --delete-secret-keys YOUR_KEY_ID
gpg --import subkeys-backup.asc
# Insert backup YubiKey
gpg --edit-key YOUR_KEY_ID
# Move keys to backup YubiKey using keytocard
```

##### Switching Between YubiKeys

**With the same key on both YubiKeys:**
```bash
# Remove cached key stub and re-detect
gpg-connect-agent "scd serialno" "learn --force" /bye

# Or fully reset the agent
gpgconf --kill gpg-agent
gpg --card-status
```

**With different keys on each YubiKey:**

This setup includes automatic key detection via a wrapper script (`~/.local/bin/gpg-auto-sign`). When you run `make gpg`, git is configured to use this wrapper which:

1. Detects which YubiKey is currently inserted
2. Reads the key ID from that YubiKey
3. Uses that key for signing, regardless of what's in `user.signingkey`

This means you can simply swap YubiKeys and git will automatically use the correct key - no manual switching required.

**Note:** You'll need to add each key's public key to GitHub separately at https://github.com/settings/keys

#### Troubleshooting GPG

1. **"No secret key" errors:**
   - Ensure your YubiKey is inserted
   - Run `gpgconf --kill gpg-agent` to restart the agent
   - Run `gpg --card-status` to verify YubiKey detection

2. **PIN prompt doesn't appear:**
   - Ensure `pinentry-mac` is installed: `brew list pinentry-mac`
   - Check gpg-agent config includes `pinentry-program`

3. **Signing fails in terminal:**
   - Ensure `GPG_TTY` is set: `export GPG_TTY=$(tty)`
   - Add this to your `.zshrc` if not already present

## Validation and Safety

The setup includes several safety features:

- **Pre-flight checks**: Validates system requirements before running
- **Backup creation**: Backs up existing SSH keys before modification
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
├── scripts/             # Helper scripts (e.g., gpg-auto-sign.sh)
├── ansible/
│   ├── files/           # Static files deployed to target machine
│   │   └── gpg/         # GPG public keys for import
│   ├── tasks/           # Individual task files
│   └── templates/       # Configuration templates
└── vars/
    └── api_keys.yml     # Encrypted secrets (create this)
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