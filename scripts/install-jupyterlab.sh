#!/bin/bash
set -e

if command -v mamba ; then
    mamba install -y jupyterlab
else
    pip3 install jupyterlab
fi
