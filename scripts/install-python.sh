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

# Install system libs
apt_install \
    dpkg-dev \
    libbz2-dev \
    libc6-dev \
    libdb-dev \
    libffi-dev \
    libgdbm-dev \
    liblzma-dev \
    libncursesw5-dev \
    libreadline-dev \
    libssl-dev \
    tk-dev \
    uuid-dev \
    xz-utils \
    zlib1g-dev

# Install Python
wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
tar xzvf Python-${PYTHON_VERSION}.tgz
cd Python-${PYTHON_VERSION}
./configure \
		--enable-optimizations \
		--enable-shared \
		--with-lto \
		--with-ensurepip
make -j 8  # GHA's public VM have 4 cores
make install
ldconfig

# Checks
python3 --version
python3 -m ensurepip --upgrade

# Useful symlinks
ln -s /usr/local/bin/python3 /usr/local/bin/python
ln -s /usr/local/bin/pip3 /usr/local/bin/pip

# Clean
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false
rm -rf /var/lib/apt/lists/*
