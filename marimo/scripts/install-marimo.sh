#!/bin/bash
set -e

# Install marimo
uv pip install --system --no-cache marimo

# Clean install files
rm -rf $HOME/.cache
