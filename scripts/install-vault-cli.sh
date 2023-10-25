#!/bin/bash
set -e

VAULT_LATEST_VERSION=$(curl --silent "https://api.github.com/repos/hashicorp/vault/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")')
wget -q https://releases.hashicorp.com/vault/${VAULT_LATEST_VERSION}/vault_${VAULT_LATEST_VERSION}_linux_amd64.zip -O vault.zip
unzip vault.zip -d /usr/local/bin/
vault -autocomplete-install
rm vault.zip
