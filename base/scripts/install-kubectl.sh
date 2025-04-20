#!/bin/bash
set -e

ARCH=$(uname -m)

case $ARCH in
    "x86_64")
        ARCHITECTURE="amd64"
        ;;
    "aarch64")
        ARCHITECTURE="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/$ARCHITECTURE/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
echo 'source <(kubectl completion bash)' >> ${HOME}/.bashrc
