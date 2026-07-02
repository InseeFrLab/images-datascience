#!/bin/bash
set -e

# Ensure writable directories are owned by root and group-writable
# This creates duplicate files in Docker layers for files that already have these permissions.
for dir in "${HOME}" /opt /usr/local; do
    # Skip CUDA directories
    if [[ "$dir" == "/usr/local" ]]; then
        # Give user permisssions on all files in /usr/local except cuda folders
        find "$dir" -path "$dir/cuda*" -prune -o \
            -execdir chgrp 0 {} \; -execdir chmod g+rwX {} \;
    else
        chgrp -R 0 "$dir"
        chmod -R g+rwX "$dir"
    fi
done
