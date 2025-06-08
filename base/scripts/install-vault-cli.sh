#!/bin/bash
set -e

# If vault is already installed, exit with success.
# The alias will be removed just as in the case of a successful install
if which vault > /dev/null 2>&1; then
    echo "Vault CLI is already installed, removing alias."
    echo "You may try again your command."
    exit 0
fi

# Warn the user that they are about to install vault and await confirmation
read -p "Vault CLI is not installed by default in this datascience environment. Install it now? [y/N] " yn
if [[ ! "$yn" =~ ^[Yy]$ ]]; then
    # Skip install and politely explain how to remove alias
    echo "Skipping vault install."
    echo "To stop seeing this message when running vault:"
    echo '  sed -i "/alias vault=/d" ~/.bashrc && unalias vault'
    exit 1
fi

echo "Installing Vault..."

# Install latest version of vault
ARCH=$(uname -m)
case $ARCH in
    "x86_64")
        ARCHITECTURE="amd64"
        ;;
    "aarch64")
        ARCHITECTURE="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac
VAULT_LATEST_VERSION=$(curl --silent "https://api.github.com/repos/hashicorp/vault/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")')
wget -q https://releases.hashicorp.com/vault/${VAULT_LATEST_VERSION}/vault_${VAULT_LATEST_VERSION}_linux_${ARCHITECTURE}.zip -O vault.zip
unzip vault.zip -d /usr/local/bin/
vault -autocomplete-install

# Clean install files
rm vault.zip

# Check install success
if which vault > /dev/null 2>&1; then
    echo "Vault CLI was successfully installed."
    echo "You may try again your vault command."
    exit 0
else
    echo "Something went wront while installing Vault CLI..."
    echo "To stop seeing this message, run:"
    echo '  sed -i "/alias vault=/d" ~/.bashrc && unalias vault'
    exit 1
fi
