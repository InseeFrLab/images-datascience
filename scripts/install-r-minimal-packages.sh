#!/bin/bash
set -e

# Install required system libraries

function apt_install() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            apt-get update
        fi
        apt-get install -y --no-install-recommends "$@"
    fi
}

apt_install \
    libglpk40 \
    libpq-dev \
    libzmq3-dev

# Install R packages

install2.r --ncpus -1 --error \
    arrow \
    aws.s3 \
    devtools \
    DBI \
    duckdb \
    lintr \
    paws \
    quarto \
    renv \
    RPostgreSQL \
    styler \
    targets
