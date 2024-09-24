.PHONY: all deps install-personal install-work dock setup install-keys

all: setup deps install-personal

work: setup deps install-work

deps:
	@echo "Installing dependencies..."
	@ansible-galaxy role install -f -r requirements.yaml
	@ansible-galaxy collection install -f -r requirements.yaml

install-personal:
	@ansible-playbook local.yaml --tags install,personal

install-work:
	@ansible-playbook local.yaml --tags install,work

install-keys:
	@ansible-playbook personal-keys.yaml -K --ask-vault-pass

dock:
	@ansible-playbook local.yaml --tags dock

setup:
	@ansible-playbook setup.yaml --ask-become-pass