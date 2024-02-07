#!/bin/bash
set -e

# a function to install apt packages only if they are not installed
# source : https://github.com/rocker-org/rocker-versioned2/blob/master/scripts
function apt_install() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            apt-get update
        fi
        apt-get install -y --no-install-recommends "$@"
    fi
}

apt_install \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    git \
    gnupg2 \
    jq \
    less \
    locales \
    lsb-core \
    nano \
    openssh-client \
    python3-pip \
    sudo \
    tini \
    unzip \
    vim \
    wget \
    libbz2-dev # for jdk
