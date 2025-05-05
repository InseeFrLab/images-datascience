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

# Install system libraries for geospatial computation
add-apt-repository -y ppa:ubuntugis/ppa
apt_install \
    libgdal-dev \
    gdal-bin

# Install GDAL Python package with numpy-based raster support
# See : https://pypi.org/project/GDAL/
uv pip install --system numpy>1.0.0 wheel setuptools>=67
pip install gdal[numpy]=="$(gdal-config --version).*"
