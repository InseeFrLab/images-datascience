#!/bin/bash
set -e

# Add custom PPAs to get most up-to-date software
apt-get update
apt-get install -y --no-install-recommends gnupg2 software-properties-common wget
# PPA for git
add-apt-repository -y ppa:git-core/ppa
# PPA for postgresql-client
echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Install system libraries
apt-get update
apt-get install -y --no-install-recommends \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    git \
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
    vim
