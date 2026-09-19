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

KUBECTL_VERSION=$(curl -fsSL https://dl.k8s.io/release/stable.txt)
curl -fsSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCHITECTURE}/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
echo 'source <(kubectl completion bash)' >> ${HOME}/.bashrc
