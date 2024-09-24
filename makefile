.PHONY: all deps install-personal install-work dock setup install-keys sudo_prompt

# Function to prompt for sudo password and verify sudo access
define sudo_prompt
	@if [ -z "$(SUDO_PASSWORD)" ]; then \
		read -s -p "Enter your sudo password: " SUDO_PASSWORD; \
		echo; \
		if ! echo "$$SUDO_PASSWORD" | sudo -S echo "Sudo access granted" >/dev/null 2>&1; then \
			echo "Sudo access denied. Please try again."; \
			exit 1; \
		fi; \
		export SUDO_PASSWORD; \
	fi
endef

all: setup deps install-personal

work: setup deps install-work

deps:
	@echo "Installing dependencies..."
	@ansible-galaxy role install -f -r requirements.yaml
	@ansible-galaxy collection install -f -r requirements.yaml

install-personal: sudo_prompt
	@ANSIBLE_BECOME_PASS="$$SUDO_PASSWORD" ansible-playbook local.yaml --tags install,personal

install-work: sudo_prompt
	@ANSIBLE_BECOME_PASS="$$SUDO_PASSWORD" ansible-playbook local.yaml --tags install,work

install-keys: sudo_prompt
	@ANSIBLE_BECOME_PASS="$$SUDO_PASSWORD" ansible-playbook personal-keys.yaml --ask-vault-pass

dock:
	@ansible-playbook local.yaml --tags dock

setup: sudo_prompt
	@ANSIBLE_BECOME_PASS="$$SUDO_PASSWORD" ansible-playbook setup.yaml

sudo_prompt:
	$(call sudo_prompt)