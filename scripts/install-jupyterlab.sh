#!/bin/bash
set -e

# If Conda is installed, use it to install Jupyterlab
if command -v mamba ; then
    mamba install -y jupyterlab
else
# Else, install via pip
    pip install jupyterlab
fi
