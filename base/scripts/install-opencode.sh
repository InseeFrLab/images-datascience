#!/bin/bash
set -e

# Install opencode using the official installer
curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path

# Make opencode available system-wide
mv ${HOME}/.opencode/bin/opencode /usr/local/bin/opencode
rm -rf ${HOME}/.opencode
