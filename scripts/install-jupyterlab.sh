#!/bin/bash
set -e

if command -v mamba ; then
    mamba install -y jupyterlab
else
    if [ "`which pip3`" = "" ]; then
        apt-get update
        apt-get install -y --no-install-recommends python3-pip
    fi
    pip3 install jupyterlab
fi
