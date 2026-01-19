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

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"linux/$ARCHITECTURE/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
echo 'source <(kubectl completion bash)' >> ${HOME}/.bashrc
