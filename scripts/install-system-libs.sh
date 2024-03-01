#!/bin/bash
set -e

# PPA for postgresql-client
echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

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
    postgresql-client \
    python3-pip \
    sudo \
    tini \
    unzip \
    vim \
    wget
