#!/bin/bash

if ! command -v brew &> /dev/null
then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    exit
fi

if ! command -v ansible &> /dev/null
then
    brew install ansible
    ansible-galaxy collection install community.general
    exit
fi


