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

# Install system libraries required to build Python from source
savedAptMark="$(apt-mark showmanual)"
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
    libsqlite3-dev \
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
        --enable-loadable-sqlite-extensions \
		--enable-optimizations \
		--enable-shared \
		--with-lto
make -j4
make install
ldconfig

# Useful symlinks
ln -s /usr/local/bin/python3 /usr/local/bin/python
ln -s /usr/local/bin/pip3 /usr/local/bin/pip

# Checks
python --version

# Clean install files
cd ..
rm -rf Python-${PYTHON_VERSION}.tgz Python-${PYTHON_VERSION}
apt-mark auto '.*' > /dev/null
apt-mark manual $savedAptMark
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# Upgrade pip & install uv for further Python packages installation
pip install --no-cache-dir --upgrade pip
pip install --no-cache-dir uv
