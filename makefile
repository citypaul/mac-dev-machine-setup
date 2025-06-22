.PHONY: all deps personal work dock setup keys cli gui update check

all: setup deps install personal

work: setup deps install work

dotfiles:
	@ansible-playbook local.yaml --tags dotfiles

deps:
	@echo "Installing dependencies..."
	@ansible-galaxy role install -f -r requirements.yaml
	@ansible-galaxy collection install -f -r requirements.yaml

install:
	@ansible-playbook local.yaml -K --tags install

personal: 
	@ansible-playbook local.yaml -K --tags personal

work: 
	@ansible-playbook local.yaml -K --tags work

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
	@ansible-playbook setup.yaml -K

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