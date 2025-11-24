.PHONY: all deps personal work dock setup keys cli gui update check

all: setup deps install personal

work-setup: setup deps install work-tag

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
	@ansible-playbook local.yaml -K --tags install

personal: 
	@ansible-playbook local.yaml -K --tags personal

work-tag: 
	@ansible-playbook local.yaml -K --tags work

work: work-setup

git:
	@ansible-playbook local.yaml --tags git-personal -K

keys: 
	@ansible-playbook personal-keys.yaml -K --ask-vault-pass

cli: 
	@ansible-playbook local.yaml --tags cli -K

gui: 
	@ansible-playbook local.yaml --tags gui -K

osx: 
	@ansible-playbook local.yaml --tags osx -K 

dock:
	@ansible-playbook local.yaml --tags dock 

setup: 
	@ansible-playbook setup.yaml

fonts:
	@ansible-playbook local.yaml --tags fonts

themes:
	@ansible-playbook local.yaml --tags themes

app-store:
	@ansible-playbook local.yaml --tags app-store -K

update:
	@echo "Updating all installed packages..."
	@ansible-playbook update.yaml -K

check:
	@echo "Running in check mode (dry run)..."
	@ansible-playbook local.yaml -K --check --diff

node:
	@ansible-playbook local.yaml --tags node