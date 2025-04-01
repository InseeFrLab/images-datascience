#!/bin/bash
set -e

# Install code-server
wget https://code-server.dev/install.sh
chmod +x install.sh
./install.sh
rm install.sh

# Fix permissions on VSCode's extensions directory
chown -R ${USERNAME}:${GROUPNAME} ~/.local/share/code-server/extensions/

# Clean install files
rm -rf $HOME/.cache
