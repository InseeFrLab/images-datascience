#!/bin/bash
set -e

HELM_VERSION="4.3.0"

# Download the official release archive and verify its checksum
HELM_ARCHIVE="helm-v${HELM_VERSION}-linux-amd64.tar.gz"
TMP_DIR=$(mktemp -d)
curl -fsSL "https://get.helm.sh/${HELM_ARCHIVE}" -o "${TMP_DIR}/${HELM_ARCHIVE}"
curl -fsSL "https://get.helm.sh/${HELM_ARCHIVE}.sha256sum" -o "${TMP_DIR}/${HELM_ARCHIVE}.sha256sum"
(cd "${TMP_DIR}" && sha256sum --check "${HELM_ARCHIVE}.sha256sum")

# Install Helm
tar -xzf "${TMP_DIR}/${HELM_ARCHIVE}" -C "${TMP_DIR}"
install -m 0755 "${TMP_DIR}/linux-amd64/helm" /usr/local/bin/helm
rm -rf "${TMP_DIR}"

echo 'source <(helm completion bash)' >> ${HOME}/.bashrc
