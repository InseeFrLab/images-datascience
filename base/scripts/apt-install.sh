#!/bin/bash
set -e

# Install apt packages that are not installed yet, refreshing package lists if they were cleaned

if ! dpkg -s "$@" >/dev/null 2>&1; then
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        apt-get update
    fi
    apt-get install -y --no-install-recommends "$@"
fi
