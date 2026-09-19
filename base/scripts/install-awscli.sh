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

# Work in a temporary directory to avoid leaving install files in the image
TMP_DIR=$(mktemp -d)
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-$DIRECTORY.zip" -o "${TMP_DIR}/awscliv2.zip"
unzip -q "${TMP_DIR}/awscliv2.zip" -d "${TMP_DIR}"
"${TMP_DIR}/aws/install"
chmod +x /usr/local/bin/aws
rm -rf "${TMP_DIR}"
