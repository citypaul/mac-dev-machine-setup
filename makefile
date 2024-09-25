.PHONY: all deps personal work dock setup keys cli gui


all: setup deps personal

work: setup deps work

deps:
	@echo "Installing dependencies..."
	@ansible-galaxy role install -f -r requirements.yaml
	@ansible-galaxy collection install -f -r requirements.yaml

personal: 
	@ansible_become_pass="$$SUDO_PASSWORD" ansible-playbook local.yaml -K --tags install,personal

work: 
	@ansible_become_pass="$$SUDO_PASSWORD" ansible-playbook local.yaml -K --tags install,work

keys: 
	@ansible_become_pass="$$SUDO_PASSWORD" ansible-playbook personal-keys.yaml -K --ask-vault-pass

cli: 
	@ansible_become_pass="$$SUDO_PASSWORD" ansible-playbook local.yaml --tags cli

gui: 
	@ansible_become_pass="$$SUDO_PASSWORD" ansible-playbook local.yaml --tags gui

osx: 
	@ansible_become_pass="$$SUDO_PASSWORD" ansible-playbook local.yaml --tags osx

dock:
	@ansible-playbook local.yaml --tags dock

setup: 
	@ansible_become_pass="$$SUDO_PASSWORD" ansible-playbook setup.yaml -K