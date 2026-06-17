# Mac Dev Machine Setup

Automated setup and maintenance for my macOS development machines using Ansible, Homebrew Bundle, and a small set of make targets.

## Assumptions

1. `new-mac.sh` installs 1Password and 1Password CLI; 1Password still needs to be configured as the SSH agent before the full setup runs.
2. Personal and work GitHub SSH public keys are exported from 1Password and stored in this repo under `.ssh/`.
3. The Mac App Store is signed in before App Store apps are installed.

## Quick Start

For a fresh Mac, run the bootstrap script first:

```bash
./new-mac.sh
```

After the bootstrap finishes, open 1Password, sign in, and enable the 1Password SSH agent.

Then run one of the setup targets:

```bash
make        # personal machine
make work   # work machine
```

The legacy `./install.sh` wrapper runs the same fresh-machine path: `./new-mac.sh` followed by `make`.

## Commands

| Command          | Description                                                                 |
| ---------------- | --------------------------------------------------------------------------- |
| `make`           | Bootstrap dependencies and run the personal setup                           |
| `make work`      | Bootstrap dependencies and run the work setup                               |
| `make setup`     | Run prerequisite setup checks                                               |
| `make deps`      | Install Ansible Galaxy requirements                                         |
| `make check`     | Validate Brewfiles and Ansible syntax                                       |
| `make update`    | Update Homebrew, casks, App Store apps, npm/pnpm globals, and Ollama models |
| `make cli`       | Install command-line packages                                               |
| `make gui`       | Install GUI packages                                                        |
| `make app-store` | Install Mac App Store apps                                                  |
| `make osx`       | Apply macOS defaults                                                        |
| `make dock`      | Configure the Dock                                                          |
| `make dotfiles`  | Clone and install dotfiles                                                  |
| `make git`       | Configure Git identity and defaults                                         |
| `make node`      | Install nvm-managed Node LTS                                                |

## Package Inventory

Package lists live in Brewfiles:

```ruby
# Brewfile.cli
brew "ripgrep"

# Brewfile.gui
cask "firefox", greedy: true

# Brewfile.app-store
mas "Things", id: 904280696

# Brewfile.personal
cask "personal-only-app", greedy: true

# Brewfile.work
cask "work-only-app", greedy: true
```

Shared package inventory is split into `Brewfile.cli`, `Brewfile.gui`, and `Brewfile.app-store`. `Brewfile.personal` and `Brewfile.work` are available for profile-specific additions.

External-tap packages live in `Brewfile.cli-optional` and `Brewfile.gui-optional`. Those packages are useful, but they are allowed to fail without stopping the rest of the machine setup because third-party taps can move, disappear, or require manual trust.

## Configuration

Shared variables live in `defaults.yaml`, including:

- `machine_type`
- Git name and email
- dotfiles repo and branch
- public SSH key filenames
- global pnpm packages

The 1Password SSH config is rendered from `ansible/templates/ssh_config.j2`. `machine_type=personal` uses `personal_github.pub` for `github.com` and exposes the work key through `github-alt.com`; `machine_type=work` flips those identities.

## Validation

Run:

```bash
make check
```

This validates Brewfile parsing and runs Ansible syntax checks for:

- `setup.yaml`
- `local.yaml`
- `update.yaml`

The repo uses a local ignored Ansible temp directory via `ansible.cfg`, so syntax checks do not need to write under `~/.ansible/tmp`.

## File Structure

```text
.
├── makefile
├── new-mac.sh
├── install.sh
├── defaults.yaml
├── local.yaml
├── setup.yaml
├── update.yaml
├── Brewfile.*
├── requirements.yaml
├── ansible/
│   ├── tasks/
│   └── templates/
└── scripts/
    └── with-sudo-askpass.sh
```

## Links

1. [Dotfiles](https://github.com/mintuz/.dotfiles)
2. [1Password SSH Docs](https://developer.1password.com/docs/ssh)
3. [1Password CLI Docs](https://developer.1password.com/docs/cli/verify)
