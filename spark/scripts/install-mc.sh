#!/bin/bash
set -e

ARCH=$(uname -m)

case $ARCH in
    "x86_64")
        DIRECTORY="linux-amd64"
        ;;
    "aarch64")
        DIRECTORY="linux-arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

wget -q https://dl.min.io/client/mc/release/$DIRECTORY/mc -O /usr/local/bin/mc
chmod +x /usr/local/bin/mc
