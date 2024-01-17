#!/bin/bash
set -e

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
rm vault.zip
