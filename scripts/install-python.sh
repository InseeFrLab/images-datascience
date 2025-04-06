#!/bin/bash
set -e

# Install uv and add it to the PATH
curl -LsSf https://astral.sh/uv/install.sh | bash
source $HOME/.local/bin/env

if uv python list | grep -q ${PYTHON_VERSION}; then
    /opt/install-python-uv.sh
else
    /opt/install-python-source.sh
fi
