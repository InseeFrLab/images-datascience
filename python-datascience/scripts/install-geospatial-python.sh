#!/bin/bash
set -e

# Install system libraries for geospatial computation from the ubuntugis PPA (more recent GDAL),
# then remove the PPA so that no other package comes from it
add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable
/opt/apt-install.sh \
    libgdal-dev \
    gdal-bin
add-apt-repository -y --remove ppa:ubuntugis/ubuntugis-unstable
apt-get update

# Install GDAL Python package with numpy-based raster support, matching the system libgdal version
# See : https://pypi.org/project/GDAL/
uv pip install --system --no-cache "gdal[numpy]==$(gdal-config --version).*"
python -c "from osgeo import gdal_array"
