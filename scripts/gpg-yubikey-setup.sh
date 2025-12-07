#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Ensure we can read from terminal even when run through make
exec < /dev/tty

echo -e "${GREEN}=== GPG YubiKey Setup ===${NC}"
echo ""

echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v gpg &> /dev/null; then
    echo -e "${RED}Error: gpg not installed. Run 'make cli' first.${NC}"
    exit 1
fi

if ! command -v ykman &> /dev/null; then
    echo -e "${RED}Error: ykman not installed. Run 'make cli' first.${NC}"
    exit 1
fi

echo -e "${YELLOW}Checking for YubiKey...${NC}"
if ! ykman info &> /dev/null; then
    echo -e "${RED}Error: No YubiKey detected. Please insert your YubiKey.${NC}"
    exit 1
fi
echo -e "${GREEN}YubiKey detected!${NC}"

echo ""
echo -e "${YELLOW}Preparing GPG for YubiKey access...${NC}"

# Kill any existing GPG daemons that might be holding the device
gpgconf --kill scdaemon 2>/dev/null || true
gpgconf --kill gpg-agent 2>/dev/null || true

# Check if macOS pcscd is conflicting with GPG's scdaemon
if sudo launchctl list 2>/dev/null | grep -q "com.apple.pcscd"; then
    echo -e "${YELLOW}Disabling macOS smart card daemon (conflicts with GPG)...${NC}"
    sudo launchctl disable system/com.apple.pcscd 2>/dev/null || true
    sudo pkill -9 pcscd 2>/dev/null || true
    sleep 1
fi

# Verify GPG can now access the card
if ! gpg --card-status &>/dev/null; then
    echo -e "${RED}Error: GPG cannot access YubiKey.${NC}"
    echo "Try unplugging and reinserting your YubiKey, then run this script again."
    exit 1
fi
echo -e "${GREEN}GPG can access YubiKey!${NC}"

echo ""
echo -e "${YELLOW}Checking for existing GPG key on YubiKey...${NC}"
EXISTING_KEY=$(gpg --card-status 2>/dev/null | grep -E "^sec" | head -1 || true)

if [ -n "$EXISTING_KEY" ]; then
    KEY_ID=$(gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep -E "^sec" | head -1 | awk -F'/' '{print $2}' | awk '{print $1}')
    echo -e "${GREEN}Found existing key: $KEY_ID${NC}"
    echo ""
    echo "Your git will be configured to use this key for signing."
    echo "Run 'make gpg' to apply the configuration."
    exit 0
fi

echo -e "${YELLOW}No existing GPG key found on YubiKey.${NC}"
echo ""

echo "What would you like to do?"
echo "  1) Generate a new key directly on YubiKey (most secure)"
echo "  2) Import an existing key to YubiKey"
echo "  3) Exit"
echo ""
printf "Choose option [1-3]: "
read -r choice

case $choice in
    1)
        echo ""
        echo -e "${YELLOW}=== Generating New Key on YubiKey ===${NC}"
        echo ""
        echo -e "${YELLOW}IMPORTANT: Backup Decision${NC}"
        echo "Keys generated on YubiKey CANNOT be extracted later."
        echo "If you have a backup YubiKey, choose YES for off-card backup."
        echo ""
        echo "This will launch the GPG card interface."
        echo "Follow these steps:"
        echo "  1. Type 'admin' and press Enter"
        echo "  2. Type 'generate' and press Enter"
        echo "  3. Off-card backup? Choose YES if you have a backup YubiKey"
        echo "     (Creates ~/.gnupg/sk_*.gpg - store this securely!)"
        echo "  4. Set key expiration (recommended: 2y for 2 years)"
        echo "  5. Enter your name: Paul Hammond"
        echo "  6. Enter your email: paul.hammond@gmail.com"
        echo "  7. Set your PIN when prompted (default is 123456)"
        echo "  8. Set your Admin PIN when prompted (default is 12345678)"
        echo "  9. Type 'quit' when done"
        echo ""
        printf "Press Enter to continue..."
        read -r _
        gpg --card-edit

        echo ""
        echo -e "${GREEN}Key generation complete!${NC}"

        # Check for backup file
        BACKUP_FILE=$(ls -t ~/.gnupg/sk_*.gpg 2>/dev/null | head -1)
        if [ -n "$BACKUP_FILE" ]; then
            echo ""
            echo -e "${YELLOW}Backup key created: $BACKUP_FILE${NC}"
            echo "Store this file securely to restore to a backup YubiKey later."
            echo "See 'Backup YubiKey Setup' in README.md for restore instructions."
        fi
        ;;
    2)
        echo ""
        echo -e "${YELLOW}=== Importing Existing Key ===${NC}"
        echo ""
        printf "Enter path to your private key file: "
        read -r key_path

        if [ ! -f "$key_path" ]; then
            echo -e "${RED}Error: File not found: $key_path${NC}"
            exit 1
        fi

        echo "Importing key..."
        gpg --import "$key_path"

        echo ""
        echo "Now we'll move the key to your YubiKey."
        echo -e "${RED}WARNING: This is destructive - the key will be moved, not copied!${NC}"
        echo "Make sure you have a backup of your key."
        echo ""
        printf "Press Enter to continue or Ctrl+C to cancel..."
        read -r _

        KEY_ID=$(gpg --list-secret-keys --keyid-format=long | grep -E "^sec" | head -1 | awk -F'/' '{print $2}' | awk '{print $1}')
        echo "Moving key $KEY_ID to YubiKey..."
        gpg --edit-key "$KEY_ID" keytocard
        ;;
    3)
        echo "Exiting."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${YELLOW}Verifying setup...${NC}"
gpgconf --kill gpg-agent
sleep 1

KEY_ID=$(gpg --list-secret-keys --keyid-format=long 2>/dev/null | grep -E "^sec" | head -1 | awk -F'/' '{print $2}' | awk '{print $1}')

if [ -n "$KEY_ID" ]; then
    echo -e "${GREEN}Success! Your GPG key ID is: $KEY_ID${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run 'make gpg' to configure git signing"
    echo "  2. Add your public key to GitHub: https://github.com/settings/keys"
    echo ""
    echo "To export your public key:"
    echo "  gpg --armor --export $KEY_ID"
else
    echo -e "${RED}Warning: Could not verify key setup.${NC}"
    echo "Try running 'gpg --card-status' to check."
fi
