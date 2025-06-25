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

# Set prefix
PREFIX="/opt/python-${PYTHON_VERSION}"
mkdir -p "${PREFIX}"

# Install Python
wget -q https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
tar xzvf Python-${PYTHON_VERSION}.tgz
cd Python-${PYTHON_VERSION}
./configure \
    --prefix="${PREFIX}" \
    --enable-loadable-sqlite-extensions \
    --enable-optimizations \
    --enable-shared \
    --with-lto
make -j"$(nproc)"
make altinstall

# Register libpython in ldconfig
echo "${PREFIX}/lib" > "/etc/ld.so.conf.d/python-${PYTHON_VERSION}.conf"
ldconfig

# Useful symlinks
MAJOR_MINOR="${PYTHON_VERSION%.*}"
ln -sf "${PREFIX}/bin/python${MAJOR_MINOR}" "${PREFIX}/bin/python"
ln -sf "${PREFIX}/bin/pip${MAJOR_MINOR}" "${PREFIX}/bin/pip"
ln -sf "${PREFIX}/bin/pip${MAJOR_MINOR}" "${PREFIX}/bin/pip3"
# Create symlinks in /usr/local/bin for retro-compatibility
ln -sf /opt/python-${PYTHON_VERSION}/bin/python /usr/local/bin/python && \
ln -sf /opt/python-${PYTHON_VERSION}/bin/pip /usr/local/bin/pip


# Checks
"${PREFIX}/bin/python" --version

# Clean install files
cd ..
rm -rf Python-${PYTHON_VERSION}.tgz Python-${PYTHON_VERSION}
apt-mark auto '.*' > /dev/null
apt-mark manual $savedAptMark
apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# Upgrade pip & install uv
"${PREFIX}/bin/pip3" install --no-cache-dir --upgrade pip
"${PREFIX}/bin/pip3" install --no-cache-dir uv