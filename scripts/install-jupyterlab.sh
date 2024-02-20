#!/bin/bash
set -e

source ./utils.sh

if command -v mamba ; then
    mamba install -y jupyterlab
else
    if [ "`which pip3`" = "" ]; then
        apt_install python3-pip
    fi
    pip3 install jupyterlab
fi
