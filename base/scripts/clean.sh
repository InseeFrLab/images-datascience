#!/bin/bash
set -e

rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    "$@"
