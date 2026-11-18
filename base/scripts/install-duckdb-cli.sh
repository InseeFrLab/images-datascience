#!/bin/bash
set -eo pipefail

# renovate: datasource=github-releases depName=duckdb/duckdb
DUCKDB_VERSION="2.0.0"

# Download the CLI
DUCKDB_CLI_URL="https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/duckdb-cli-linux-amd64.tar.gz"
DUCKDB_ARCHIVE=$(basename "${DUCKDB_CLI_URL}")
TMP_DIR=$(mktemp -d)
curl -fsSL "${DUCKDB_CLI_URL}" -o "${TMP_DIR}/${DUCKDB_ARCHIVE}"

# Checksum
DUCKDB_RELEASE_URL="https://api.github.com/repos/duckdb/duckdb/releases/tags/v${DUCKDB_VERSION}"
DUCKDB_SHA256=$(curl -fsSL "${DUCKDB_RELEASE_URL}" |
    jq -er --arg asset "${DUCKDB_ARCHIVE}" '.assets[] | select(.name == $asset) | .digest // empty | sub("^sha256:"; "")')
echo "${DUCKDB_SHA256}  ${TMP_DIR}/${DUCKDB_ARCHIVE}" | sha256sum --check --strict

# Install DuckDB CLI
tar -xzf "${TMP_DIR}/${DUCKDB_ARCHIVE}" -C /usr/local/bin/
rm -rf "${TMP_DIR}"
