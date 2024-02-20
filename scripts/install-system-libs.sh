#!/bin/bash
set -e

source ./utils.sh

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
    wget
