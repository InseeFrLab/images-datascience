#/bin/bash

# If Conda is installed, use it to install Jupyterlab
if command -v mamba ; then
    mamba install -y jupyterlab jupyterlab-git
else
# Else, install via pip
    if [ "`which pip3`" = "" ]; then
        apt-get update
        apt-get install -y --no-install-recommends python3-pip
    fi
    pip install jupyterlab jupyterlab-git
fi
