#!/bin/bash
set -e

function apt_install() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            apt-get update
        fi
        apt-get install -y --no-install-recommends "$@"
        apt-mark manual "$@"
    fi
}

apt_install \
    libglpk40 \
    libpq-dev \
    libzmq3-dev
