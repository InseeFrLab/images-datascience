#!/bin/bash
set -e

function apt_install() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            apt-get update
        fi
        apt-get install -y --no-install-recommends "$@"
    fi
}

if command -v mamba ; then
    mamba install -y jupyterlab
else
    if [ "`which pip3`" = "" ]; then
        apt_install python3-pip
    fi
    pip3 install jupyterlab
fi
