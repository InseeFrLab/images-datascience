#!/bin/bash
set -eo pipefail

# renovate: datasource=github-releases depName=quarto-dev/quarto-cli
QUARTO_VERSION="1.10.19"

# Download the official archive
QUARTO_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.tar.gz"
QUARTO_ARCHIVE=$(basename "${QUARTO_URL}")
TMP_DIR=$(mktemp -d)
curl -fsSL "${QUARTO_URL}" -o "${TMP_DIR}/${QUARTO_ARCHIVE}"

# Checksum
QUARTO_CHECKSUMS_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-checksums.txt"
QUARTO_CHECKSUMS=$(basename "${QUARTO_CHECKSUMS_URL}")
curl -fsSL "${QUARTO_CHECKSUMS_URL}" -o "${TMP_DIR}/${QUARTO_CHECKSUMS}"
(cd "${TMP_DIR}" && grep -F "  ${QUARTO_ARCHIVE}" "${QUARTO_CHECKSUMS}" | sha256sum --check --strict)

# Install quarto
tar -C /usr/local/lib -xzf "${TMP_DIR}/${QUARTO_ARCHIVE}"
ln -s "/usr/local/lib/quarto-${QUARTO_VERSION}/bin/quarto" /usr/local/bin/quarto
rm -rf "${TMP_DIR}"

# Check install succeeded
quarto check

# Install TinyTeX to enable rendering PDF documents via quarto
quarto install tinytex --update-path --quiet
