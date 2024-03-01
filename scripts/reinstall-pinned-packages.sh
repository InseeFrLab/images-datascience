#!/bin/bash
set -e

if [[ -n "$PINNED_APT_PACKAGES" ]]; then
    apt-get update
    apt-get install -y --no-install-recommends $PINNED_APT_PACKAGES
fi
