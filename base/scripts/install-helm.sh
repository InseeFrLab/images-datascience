#!/bin/bash
set -e

# renovate: datasource=github-releases depName=helm/helm
HELM_VERSION="4.3.1"

# Download the official release
HELM_URL="https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz"
HELM_ARCHIVE=$(basename "${HELM_URL}")
TMP_DIR=$(mktemp -d)
curl -fsSL "${HELM_URL}" -o "${TMP_DIR}/${HELM_ARCHIVE}"

# Checksum
HELM_CHECKSUM_URL="${HELM_URL}.sha256sum"
curl -fsSL "${HELM_CHECKSUM_URL}" -o "${TMP_DIR}/${HELM_ARCHIVE}.sha256sum"
(cd "${TMP_DIR}" && sha256sum --check "${HELM_ARCHIVE}.sha256sum")

# Install Helm
tar -xzf "${TMP_DIR}/${HELM_ARCHIVE}" -C "${TMP_DIR}"
install -m 0755 "${TMP_DIR}/linux-amd64/helm" /usr/local/bin/helm
rm -rf "${TMP_DIR}"

echo 'source <(helm completion bash)' >> ${HOME}/.bashrc
