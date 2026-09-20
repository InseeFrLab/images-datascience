#!/bin/bash
set -eo pipefail

# renovate: datasource=github-releases depName=coder/code-server
CODE_SERVER_VERSION="4.138.0"

# Download the official package and verify its checksum
CODE_SERVER_DEB="code-server_${CODE_SERVER_VERSION}_amd64.deb"
TMP_DIR=$(mktemp -d)
curl -fsSL "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/${CODE_SERVER_DEB}" -o "${TMP_DIR}/${CODE_SERVER_DEB}"
CODE_SERVER_SHA256=$(curl -fsSL "https://api.github.com/repos/coder/code-server/releases/tags/v${CODE_SERVER_VERSION}" |
    jq -er --arg asset "${CODE_SERVER_DEB}" '.assets[] | select(.name == $asset) | .digest // empty | sub("^sha256:"; "")')
echo "${CODE_SERVER_SHA256}  ${TMP_DIR}/${CODE_SERVER_DEB}" | sha256sum --check --strict

# Install code-server
dpkg -i "${TMP_DIR}/${CODE_SERVER_DEB}"
rm -rf "${TMP_DIR}"
