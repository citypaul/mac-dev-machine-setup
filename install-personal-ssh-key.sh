#!/bin/bash

ansible-playbook personal-ssh-key.yaml -K --ask-vault-pass --verbose
