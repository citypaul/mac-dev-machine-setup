.PHONY: all deps personal work dock setup keys cli gui update check gpg gpg-setup work-remove permissions

WITH_SUDO_ASKPASS = scripts/with-sudo-askpass.sh

all: setup deps permissions
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags install,personal

work-setup: setup deps permissions
	@$(WITH_SUDO_ASKPASS) /bin/bash -lc 'ansible-playbook local.yaml --tags install && brew bundle --file=Brewfile.work && ansible-playbook local.yaml --tags work'

permissions:
	@./scripts/ensure-mac-permissions.sh

dotfiles:
	@ansible-playbook local.yaml --tags dotfiles

deps:
	@echo "Installing dependencies..."
	@if grep -q "^roles:" requirements.yaml 2>/dev/null && [ -n "$$(awk '/^roles:/,/^collections:/' requirements.yaml | grep -v '^roles:' | grep -v '^collections:' | grep 'name:' || true)" ]; then \
		ansible-galaxy role install -f -r requirements.yaml; \
	else \
		echo "Skipping roles install, no requirements found"; \
	fi
	@if grep -q "^collections:" requirements.yaml 2>/dev/null && [ -n "$$(awk '/^collections:/,/^$$/' requirements.yaml | grep -v '^collections:' | grep 'name:' || true)" ]; then \
		if ! ansible-galaxy collection list | grep -q "community.general"; then \
			ansible-galaxy collection install -f -r requirements.yaml; \
		else \
			echo "Skipping collections install, already installed"; \
		fi; \
	else \
		echo "Skipping collections install, no requirements found"; \
	fi

install: permissions
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags install

personal: permissions
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags personal

work-tag: permissions
	@$(WITH_SUDO_ASKPASS) /bin/bash -lc 'brew bundle --file=Brewfile.work && ansible-playbook local.yaml --tags work'

work: work-setup

git:
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags git-personal

keys: 
	@$(WITH_SUDO_ASKPASS) ansible-playbook personal-keys.yaml

cli: 
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags cli

gui: permissions
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags gui

osx: 
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags osx

dock:
	@ansible-playbook local.yaml --tags dock 

setup: 
	@ansible-playbook setup.yaml

fonts:
	@ansible-playbook local.yaml --tags fonts

themes:
	@ansible-playbook local.yaml --tags themes

app-store:
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags app-store

update: permissions
	@echo "Updating all installed packages..."
	@$(WITH_SUDO_ASKPASS) ansible-playbook update.yaml

check:
	@echo "Checking Brewfiles..."
	@for file in Brewfile.cli Brewfile.gui Brewfile.app-store Brewfile.common Brewfile.personal Brewfile.work; do \
		HOMEBREW_NO_AUTO_UPDATE=1 brew bundle list --file="$$file" >/dev/null; \
		HOMEBREW_NO_AUTO_UPDATE=1 brew bundle list --file="$$file" --cask >/dev/null; \
		HOMEBREW_NO_AUTO_UPDATE=1 brew bundle list --file="$$file" --mas >/dev/null; \
	done
	@echo "Running in check mode (dry run)..."
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --check --diff

node:
	@ansible-playbook local.yaml --tags node

gpg:
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags gpg

gpg-setup:
	@./scripts/gpg-yubikey-setup.sh

work-remove:
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags work-remove
