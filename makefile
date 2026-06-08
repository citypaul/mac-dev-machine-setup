.PHONY: all deps personal work dock setup keys cli gui fabric fabric-codex fabric-codex-default update check gpg gpg-setup work-remove

WITH_SUDO_ASKPASS = scripts/with-sudo-askpass.sh
FABRIC_CODEX_MODEL ?= gpt-5.5
FABRIC_BIN ?= $(HOME)/.local/bin/fabric

all: setup deps
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags install,personal

work-setup: setup deps
	@$(WITH_SUDO_ASKPASS) /bin/bash -lc 'ansible-playbook local.yaml --tags install && brew bundle --file=Brewfile.work && ansible-playbook local.yaml --tags work'

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

install:
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags install

personal: 
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags personal

work-tag: 
	@$(WITH_SUDO_ASKPASS) /bin/bash -lc 'brew bundle --file=Brewfile.work && ansible-playbook local.yaml --tags work'

work: work-setup

git:
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags git-personal

keys: 
	@$(WITH_SUDO_ASKPASS) ansible-playbook personal-keys.yaml

cli: 
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags cli

gui: 
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags gui

fabric:
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags fabric
	@$(FABRIC_BIN) --setup

fabric-codex:
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags fabric
	@printf '%s\n' 'Fabric Codex setup'
	@printf '%s\n' 'Choose the Codex AI vendor in the Fabric setup menu.'
	@printf '%s\n' 'Accept the default Codex base URLs unless you are deliberately testing another backend.'
	@printf '%s\n' 'Complete the browser OpenAI login; Fabric stores CODEX_* tokens in ~/.config/fabric/.env.'
	@printf '%s\n' 'After setup, this target sets Fabric default vendor/model to Codex/$(FABRIC_CODEX_MODEL).'
	@printf '%s\n' ''
	@$(FABRIC_BIN) --setup
	@printf '%s\n' ''
	@scripts/fabric-set-default-model.sh "$(FABRIC_CODEX_MODEL)"

fabric-codex-default:
	@scripts/fabric-set-default-model.sh "$(FABRIC_CODEX_MODEL)"

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

update:
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
