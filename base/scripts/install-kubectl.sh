#!/bin/bash
set -e

# renovate: datasource=github-releases depName=kubernetes/kubernetes
KUBECTL_VERSION="1.37.0"

# Download the official binary and verify its checksum
KUBECTL_URL="https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
TMP_DIR=$(mktemp -d)
curl -fsSL "${KUBECTL_URL}" -o "${TMP_DIR}/kubectl"
KUBECTL_SHA256=$(curl -fsSL "${KUBECTL_URL}.sha256")
echo "${KUBECTL_SHA256}  ${TMP_DIR}/kubectl" | sha256sum --check --strict

# Install kubectl
install -m 0755 "${TMP_DIR}/kubectl" /usr/local/bin/kubectl
rm -rf "${TMP_DIR}"

echo 'source <(kubectl completion bash)' >> ${HOME}/.bashrc
