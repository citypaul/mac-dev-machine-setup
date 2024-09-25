#!/usr/bin/env zsh

# shellcheck disable=SC1091
if ! source ./setup.sh; then
    echo "Failed to execute setup.sh"
    exit 1
fi
