#!/bin/bash
# gpg-auto-sign.sh - Wrapper script that auto-detects the GPG key from the currently-inserted YubiKey
#
# This allows using multiple YubiKeys with different GPG keys for git commit signing.
# Git is configured to use this script as gpg.program, and it automatically detects
# which key to use based on which YubiKey is currently plugged in.

# Detect key ID from currently-inserted YubiKey
# First try: key stub in keyring (format: sec>  rsa2048/0x5D742BF97586D1E0  created: ...)
DETECTED_KEY=$(gpg --card-status 2>/dev/null | grep "^sec>" | head -1 | awk -F'/' '{print $2}' | awk '{print $1}' | sed 's/^0x//')

# Second try: read signing key fingerprint directly from card (no public key import needed)
if [ -z "$DETECTED_KEY" ]; then
    DETECTED_KEY=$(gpg --card-status 2>/dev/null | grep "^Signature key" | sed 's/.*: //' | tr -d ' ')
fi

# If still no key, just pass through to gpg normally
if [ -z "$DETECTED_KEY" ]; then
    exec gpg "$@"
fi

# Build new argument list, replacing any -u/--local-user key with detected key
args=()
skip_next=false

for arg in "$@"; do
    if $skip_next; then
        # Replace the key ID that follows -u with our detected key
        args+=("$DETECTED_KEY")
        skip_next=false
    elif [[ "$arg" == "-u" ]] || [[ "$arg" == "--local-user" ]]; then
        args+=("$arg")
        skip_next=true
    elif [[ "$arg" =~ ^-[a-zA-Z]*u$ ]]; then
        # Handle combined flags ending with u (e.g., -bsau) - next arg is the key
        args+=("$arg")
        skip_next=true
    elif [[ "$arg" =~ ^-u.+ ]]; then
        # Handle -uKEYID format (no space)
        args+=("-u$DETECTED_KEY")
    elif [[ "$arg" =~ ^--local-user=.+ ]]; then
        # Handle --local-user=KEYID format
        args+=("--local-user=$DETECTED_KEY")
    else
        args+=("$arg")
    fi
done

exec gpg "${args[@]}"
