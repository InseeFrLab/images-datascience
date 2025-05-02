#!/bin/bash
set -e

# Install latest version of quarto
LATEST_VERSION=$(curl -s https://quarto.org/docs/download/_download.json | jq -r '.version')
DL_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${LATEST_VERSION}/quarto-${LATEST_VERSION}-linux-amd64.tar.gz"
wget -q ${DL_URL} -O quarto.tar.gz
tar -C /usr/local/lib -xvzf quarto.tar.gz
ln -s "/usr/local/lib/quarto-${LATEST_VERSION}/bin/quarto" /usr/local/bin/quarto

# Check install succeeded
quarto check

# Install TinyTeX to enable rendering PDF documents via quarto
quarto install tinytex --update-path --quiet

# Clean install files
rm -f quarto.tar.gz
