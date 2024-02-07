#!/bin/bash
set -e

ARCH=$(uname -m)

case $ARCH in
    "x86_64")
        FILENAME="argo-linux-amd64"
        ;;
    "aarch64")
        FILENAME="argo-linux-arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

curl -sLO https://github.com/argoproj/argo-workflows/releases/latest/download/$FILENAME.gz
gunzip $FILENAME.gz
chmod +x $FILENAME
mv ./$FILENAME /usr/local/bin/argo
