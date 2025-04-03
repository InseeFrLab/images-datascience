#!/bin/bash
set -e

rm -rf \
    /var/lib/apt/lists/* \
    ${HOME}/.cache/ \
    /tmp/* \
    "$@"
