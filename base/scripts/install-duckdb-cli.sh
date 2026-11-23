#!/bin/bash
set -eo pipefail

# renovate: datasource=github-releases depName=duckdb/duckdb
DUCKDB_VERSION="2.0.1"

# Download the CLI
DUCKDB_CLI_URL="https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/duckdb-cli-linux-amd64.tar.gz"
DUCKDB_ARCHIVE=$(basename "${DUCKDB_CLI_URL}")
TMP_DIR=$(mktemp -d)
curl -fsSL "${DUCKDB_CLI_URL}" -o "${TMP_DIR}/${DUCKDB_ARCHIVE}"

# Checksum
# The build passes a token as the github_token secret: unauthenticated, the
# GitHub API allows 60 requests per hour per IP, shared by the CI runners
GITHUB_API_AUTH=()
if [[ -s /run/secrets/github_token ]]; then
    GITHUB_API_AUTH=(-H "Authorization: Bearer $(cat /run/secrets/github_token)")
fi
DUCKDB_RELEASE_URL="https://api.github.com/repos/duckdb/duckdb/releases/tags/v${DUCKDB_VERSION}"
DUCKDB_SHA256=$(curl -fsSL "${GITHUB_API_AUTH[@]}" "${DUCKDB_RELEASE_URL}" |
    jq -er --arg asset "${DUCKDB_ARCHIVE}" '.assets[] | select(.name == $asset) | .digest // empty | sub("^sha256:"; "")')
echo "${DUCKDB_SHA256}  ${TMP_DIR}/${DUCKDB_ARCHIVE}" | sha256sum --check --strict

# Install DuckDB CLI
tar -xzf "${TMP_DIR}/${DUCKDB_ARCHIVE}" -C /usr/local/bin/
rm -rf "${TMP_DIR}"
