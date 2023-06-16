#!/bin/zsh

ansible-playbook personal-keys.yaml -K --ask-vault-pass --verbose
