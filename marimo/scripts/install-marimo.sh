#!/bin/bash
set -e

# Install marimo
uv pip install --system --no-cache "marimo[sql]"

# Clean install files
rm -rf $HOME/.cache
