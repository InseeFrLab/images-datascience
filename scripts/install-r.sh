#!/bin/bash
set -e

# Fetch rocker's scripts
git clone --branch R${R_VERSION} --depth 1 https://github.com/rocker-org/rocker-versioned2.git
mkdir /opt/rocker_scripts
cp -a rocker-versioned2/scripts/. /opt/rocker_scripts/
chmod -R 700 /opt/rocker_scripts/

# Install R
/opt/rocker_scripts/install_R_source.sh

# Clean
rm -rf rocker-versioned2/
