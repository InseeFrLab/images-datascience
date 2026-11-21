#!/bin/bash
set -e

# renovate: datasource=github-releases depName=hickford/git-credential-oauth
GIT_CREDENTIAL_OAUTH_VERSION="0.18.0"

# Download the official archive and verify its checksum
GIT_CREDENTIAL_OAUTH_URL="https://github.com/hickford/git-credential-oauth/releases/download/v${GIT_CREDENTIAL_OAUTH_VERSION}"
GIT_CREDENTIAL_OAUTH_ARCHIVE="git-credential-oauth_${GIT_CREDENTIAL_OAUTH_VERSION}_linux_amd64.tar.gz"
TMP_DIR=$(mktemp -d)
curl -fsSL "${GIT_CREDENTIAL_OAUTH_URL}/${GIT_CREDENTIAL_OAUTH_ARCHIVE}" -o "${TMP_DIR}/${GIT_CREDENTIAL_OAUTH_ARCHIVE}"
curl -fsSL "${GIT_CREDENTIAL_OAUTH_URL}/git-credential-oauth_${GIT_CREDENTIAL_OAUTH_VERSION}_checksums.txt" -o "${TMP_DIR}/checksums.txt"
(cd "${TMP_DIR}" && sha256sum --check --strict --ignore-missing checksums.txt)

# Install git-credential-oauth
tar -xzf "${TMP_DIR}/${GIT_CREDENTIAL_OAUTH_ARCHIVE}" -C "${TMP_DIR}"
install -m 0755 "${TMP_DIR}/git-credential-oauth" /usr/local/bin/git-credential-oauth
rm -rf "${TMP_DIR}"
