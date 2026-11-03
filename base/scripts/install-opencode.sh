#!/bin/bash
set -eo pipefail

# OpenCode v2 is only published on npm (no GitHub release): the native binary ships in a per-platform package
# renovate: datasource=npm depName=@opencode/cli-linux-x64
OPENCODE_VERSION="2.2.0"

# Download the npm package
OPENCODE_URL="https://registry.npmjs.org/@opencode/cli-linux-x64/-/cli-linux-x64-${OPENCODE_VERSION}.tgz"
OPENCODE_PACKAGE=$(basename "${OPENCODE_URL}")
TMP_DIR=$(mktemp -d)
curl -fsSL "${OPENCODE_URL}" -o "${TMP_DIR}/${OPENCODE_PACKAGE}"

# Checksum: the SHA-512 recorded by the npm registry for this version
OPENCODE_METADATA_URL="https://registry.npmjs.org/@opencode/cli-linux-x64/${OPENCODE_VERSION}"
OPENCODE_SHA512=$(curl -fsSL "${OPENCODE_METADATA_URL}" |
    jq -er '.dist.integrity | select(startswith("sha512-")) | sub("^sha512-"; "")' |
    base64 -d | od -An -v -tx1 | tr -d ' \n')
echo "${OPENCODE_SHA512}  ${TMP_DIR}/${OPENCODE_PACKAGE}" | sha512sum --check --strict

# Install opencode system-wide
tar -xzf "${TMP_DIR}/${OPENCODE_PACKAGE}" -C "${TMP_DIR}"
install -m 0755 "${TMP_DIR}/package/bin/opencode" /usr/local/bin/opencode
rm -rf "${TMP_DIR}"
