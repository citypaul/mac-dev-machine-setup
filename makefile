.PHONY: all deps personal work dock setup keys cli gui

all: setup deps personal

work: setup deps work

dotfiles:
	@ansible-playbook local.yaml --tags dotfiles

deps:
	@echo "Installing dependencies..."
	@ansible-galaxy role install -f -r requirements.yaml
	@ansible-galaxy collection install -f -r requirements.yaml

personal: 
	@ansible-playbook local.yaml -K --tags personal

work: 
	@ansible-playbook local.yaml -K --tags install,work

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
