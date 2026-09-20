#!/bin/bash
set -eo pipefail

# renovate: datasource=github-releases depName=quarto-dev/quarto-cli
QUARTO_VERSION="1.10.18"

# Download the official archive and verify its checksum
QUARTO_URL="https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}"
QUARTO_ARCHIVE="quarto-${QUARTO_VERSION}-linux-amd64.tar.gz"
QUARTO_CHECKSUMS="quarto-${QUARTO_VERSION}-checksums.txt"
TMP_DIR=$(mktemp -d)
curl -fsSL "${QUARTO_URL}/${QUARTO_ARCHIVE}" -o "${TMP_DIR}/${QUARTO_ARCHIVE}"
curl -fsSL "${QUARTO_URL}/${QUARTO_CHECKSUMS}" -o "${TMP_DIR}/${QUARTO_CHECKSUMS}"
(cd "${TMP_DIR}" && grep -F "  ${QUARTO_ARCHIVE}" "${QUARTO_CHECKSUMS}" | sha256sum --check --strict)

# Install quarto
tar -C /usr/local/lib -xzf "${TMP_DIR}/${QUARTO_ARCHIVE}"
ln -s "/usr/local/lib/quarto-${QUARTO_VERSION}/bin/quarto" /usr/local/bin/quarto
rm -rf "${TMP_DIR}"

# Check install succeeded
quarto check

# Install TinyTeX to enable rendering PDF documents via quarto
quarto install tinytex --update-path --quiet
