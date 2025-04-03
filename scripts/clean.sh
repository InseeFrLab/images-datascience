#!/bin/bash
set -e

# Remove caches and temp files
rm -rf /var/lib/apt/lists/*
rm -rf ~/.cache/
rm -rf /tmp/*

# Remove files/directories supplied as args to the script
rm -rf "$@"
