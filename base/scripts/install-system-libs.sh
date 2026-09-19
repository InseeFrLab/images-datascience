#!/bin/bash
set -e

# Add custom PPAs to get most up-to-date software
apt-get update
/opt/apt-install.sh gnupg2 software-properties-common wget
# PPA for git
add-apt-repository -y ppa:git-core/ppa
# PPA for postgresql-client
mkdir -p /usr/share/keyrings

echo "deb [signed-by=/usr/share/keyrings/postgresql.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget -nv -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | tee /usr/share/keyrings/postgresql.asc > /dev/null

apt update

# Pinning postgresql
cat > /etc/apt/preferences.d/pgdg <<EOF
Package: *
Pin: release o=apt.postgresql.org
Pin-Priority: 100

Package: postgresql-* postgresql-client-* libpq5 libpq-dev
Pin: release o=apt.postgresql.org
Pin-Priority: 700
EOF

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
    postgresql-client \
    sudo \
    tini \
    unzip \
    vim
