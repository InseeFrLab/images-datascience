#!/bin/bash
set -e

# Install system libraries required by some R packages
/opt/apt-install.sh \
    cmake \
    zlib1g-dev \
    libglpk40 \
    libpq-dev \
    libzmq3-dev
