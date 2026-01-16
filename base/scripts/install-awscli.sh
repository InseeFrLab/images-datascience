#!/bin/bash
set -e

ARCH=$(uname -m)

case $ARCH in
    "x86_64")
        DIRECTORY="linux-x86_64"
        ;;
    "aarch64")
        DIRECTORY="linux-aarch64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac
curl "https://awscli.amazonaws.com/awscli-exe-$DIRECTORY.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install 
chmod +x /usr/local/bin/aws
