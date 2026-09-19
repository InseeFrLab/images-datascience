#!/bin/bash
set -e

# Add custom PPAs to get most up-to-date software
apt-get update
/opt/apt-install.sh gnupg2 software-properties-common wget
add-apt-repository -y ppa:git-core/ppa  # For Git

# Install system libraries
/opt/apt-install.sh \
    bash-completion \
    build-essential \
    ca-certificates \
    curl \
    git \
    graphviz \
    groff \
    jq \
    less \
    locales \
    nano \
    openssh-client \
    sudo \
    tini \
    unzip \
    vim

# Install the latest postgresql-client from the PostgreSQL PPA, and remove the PPA afterwards
mkdir -p /usr/share/keyrings
wget -nv -O /usr/share/keyrings/postgresql.asc https://www.postgresql.org/media/keys/ACCC4CF8.asc
echo "deb [signed-by=/usr/share/keyrings/postgresql.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
apt-get update
/opt/apt-install.sh postgresql-client libpq-dev
rm /etc/apt/sources.list.d/pgdg.list /usr/share/keyrings/postgresql.asc
apt-get update
