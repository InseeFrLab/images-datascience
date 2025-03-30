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
    libbluetooth-dev \
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
		--with-lto \
		--with-ensurepip
make -j8
sudo make install
rm -rf Python-${PYTHON_VERSION}.tgz Python-${PYTHON_VERSION}

# Add to PATH
sudo ln -fs /usr/local/bin/python /usr/bin/python${PYTHON_VERSION}
sudo ln -fs /usr/local/bin/python3 /usr/bin/python${PYTHON_VERSION}
sudo ln -fs /usr/local/bin/pip /usr/bin/pip${PYTHON_VERSION}
sudo ln -fs /usr/local/bin/pip3 /usr/bin/pip${PYTHON_VERSION}

# Ensure pip is installed
python3 -m ensurepip --upgrade
