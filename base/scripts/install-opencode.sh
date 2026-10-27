#!/bin/bash
set -eo pipefail

# OpenCode v2 is only published on npm (no GitHub release): the native binary ships in a per-platform package
# renovate: datasource=npm depName=@opencode/cli-linux-x64
OPENCODE_VERSION="2.2.0"

# Download the npm package and verify it against the SHA-512 recorded by the registry
OPENCODE_PACKAGE="cli-linux-x64-${OPENCODE_VERSION}.tgz"
TMP_DIR=$(mktemp -d)
curl -fsSL "https://registry.npmjs.org/@opencode/cli-linux-x64/-/${OPENCODE_PACKAGE}" -o "${TMP_DIR}/${OPENCODE_PACKAGE}"
OPENCODE_SHA512=$(curl -fsSL "https://registry.npmjs.org/@opencode/cli-linux-x64/${OPENCODE_VERSION}" |
    jq -er '.dist.integrity | select(startswith("sha512-")) | sub("^sha512-"; "")' |
    base64 -d | od -An -v -tx1 | tr -d ' \n')
echo "${OPENCODE_SHA512}  ${TMP_DIR}/${OPENCODE_PACKAGE}" | sha512sum --check --strict

# Install opencode system-wide
tar -xzf "${TMP_DIR}/${OPENCODE_PACKAGE}" -C "${TMP_DIR}"
install -m 0755 "${TMP_DIR}/package/bin/opencode" /usr/local/bin/opencode
rm -rf "${TMP_DIR}"
