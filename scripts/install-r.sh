#!/bin/bash
set -e

# Fetch rocker's scripts
git clone --branch R${R_VERSION} --depth 1 https://github.com/rocker-org/rocker-versioned2.git
mkdir -p /rocker_scripts
cp -a rocker-versioned2/scripts/. /rocker_scripts/
chmod -R 700 /rocker_scripts/

# Build R from source
/rocker_scripts/install_R_source.sh

# Give user ownership on R's directory for user-installed packages 
mkdir -p "${R_HOME}/site-library/"
chown -R ${USERNAME}:${GROUPNAME} "${R_HOME}/site-library/"

# Clean
rm -rf rocker-versioned2/
