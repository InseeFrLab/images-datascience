#!/bin/bash
set -e

# Install code-server
wget -q https://code-server.dev/install.sh
chmod +x install.sh
./install.sh --version 4.100.3
rm install.sh

# Clean install files
rm -rf $HOME/.cache
