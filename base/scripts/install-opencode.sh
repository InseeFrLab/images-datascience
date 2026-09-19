#!/bin/bash
set -eo pipefail

# renovate: datasource=github-releases depName=anomalyco/opencode
OPENCODE_VERSION="1.18.31"

# Download the GitHub archive and verify its checksum
OPENCODE_ARCHIVE="opencode-linux-x64.tar.gz"
TMP_DIR=$(mktemp -d)
curl -fsSL "https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/${OPENCODE_ARCHIVE}" -o "${TMP_DIR}/${OPENCODE_ARCHIVE}"
OPENCODE_SHA256=$(curl -fsSL "https://api.github.com/repos/anomalyco/opencode/releases/tags/v${OPENCODE_VERSION}" |
    jq -er --arg asset "${OPENCODE_ARCHIVE}" '.assets[] | select(.name == $asset) | .digest // empty | sub("^sha256:"; "")')
echo "${OPENCODE_SHA256}  ${TMP_DIR}/${OPENCODE_ARCHIVE}" | sha256sum --check --strict

# Install opencode system-wide
tar -xzf "${TMP_DIR}/${OPENCODE_ARCHIVE}" -C "${TMP_DIR}"
install -m 0755 "${TMP_DIR}/opencode" /usr/local/bin/opencode
rm -rf "${TMP_DIR}"
