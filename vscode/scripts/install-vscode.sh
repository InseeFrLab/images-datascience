#!/bin/bash
set -eo pipefail

# renovate: datasource=github-releases depName=coder/code-server
CODE_SERVER_VERSION="4.143.1"

# Download the official package
CODE_SERVER_URL="https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_amd64.deb"
CODE_SERVER_DEB=$(basename "${CODE_SERVER_URL}")
TMP_DIR=$(mktemp -d)
curl -fsSL "${CODE_SERVER_URL}" -o "${TMP_DIR}/${CODE_SERVER_DEB}"

# Checksum
CODE_SERVER_RELEASE_URL="https://api.github.com/repos/coder/code-server/releases/tags/v${CODE_SERVER_VERSION}"
CODE_SERVER_SHA256=$(curl -fsSL "${CODE_SERVER_RELEASE_URL}" |
    jq -er --arg asset "${CODE_SERVER_DEB}" '.assets[] | select(.name == $asset) | .digest // empty | sub("^sha256:"; "")')
echo "${CODE_SERVER_SHA256}  ${TMP_DIR}/${CODE_SERVER_DEB}" | sha256sum --check --strict

# Install code-server
dpkg -i "${TMP_DIR}/${CODE_SERVER_DEB}"
rm -rf "${TMP_DIR}"
