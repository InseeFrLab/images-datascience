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

apt_install \
    ca-certificates-java \
    libbz2-dev \
    openjdk-${JAVA_VERSION}-jdk-headless \
    openjdk-${JAVA_VERSION}-jre-headless

if command -v R; then
    R CMD javareconf
fi
