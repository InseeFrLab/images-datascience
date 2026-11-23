#!/bin/bash
set -eo pipefail

# Fetch rocker's scripts, from the tag matching the R version
ROCKER_URL="https://github.com/rocker-org/rocker-versioned2/archive/refs/tags/R${R_VERSION}.tar.gz"
mkdir -p /rocker_scripts
curl -fsSL "${ROCKER_URL}" | tar -xz -C /rocker_scripts --strip-components=2 "rocker-versioned2-R${R_VERSION}/scripts"
chmod -R 700 /rocker_scripts/

# Build R from source
/rocker_scripts/install_R_source.sh
