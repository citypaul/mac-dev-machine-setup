.PHONY: all personal work setup deps install cli gui app-store osx dock dotfiles git node update check

WITH_SUDO_ASKPASS = scripts/with-sudo-askpass.sh

all: setup deps personal

personal:
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml -e machine_type=personal

work: setup deps
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml -e machine_type=work

setup:
	@ansible-playbook setup.yaml

deps:
	@ansible-galaxy collection install -f -r requirements.yaml

install:
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags install

cli:
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags cli

gui:
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags gui

app-store:
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags app-store

osx:
	@$(WITH_SUDO_ASKPASS) ansible-playbook local.yaml --tags osx

dock:
	@ansible-playbook local.yaml --tags dock

dotfiles:
	@ansible-playbook local.yaml --tags dotfiles

git:
	@ansible-playbook local.yaml --tags git-personal

node:
	@ansible-playbook local.yaml --tags node

update:
	@$(WITH_SUDO_ASKPASS) ansible-playbook update.yaml

check:
	@echo "Checking Brewfiles..."
	@for file in Brewfile.cli Brewfile.cli-optional Brewfile.gui Brewfile.gui-optional Brewfile.app-store Brewfile.common Brewfile.personal Brewfile.work; do \
		HOMEBREW_NO_AUTO_UPDATE=1 brew bundle list --file="$$file" >/dev/null; \
	done
	@echo "Checking Ansible syntax..."
	@ansible-playbook setup.yaml --syntax-check
	@ansible-playbook local.yaml --syntax-check
	@ansible-playbook update.yaml --syntax-check
