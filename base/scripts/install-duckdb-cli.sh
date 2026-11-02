#!/bin/bash
set -eo pipefail

# renovate: datasource=github-releases depName=duckdb/duckdb
DUCKDB_VERSION="2.0.0"

# Download the GitHub archive and verify its checksum
DUCKDB_ARCHIVE="duckdb-cli-linux-amd64.tar.gz"
TMP_DIR=$(mktemp -d)
curl -fsSL "https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/${DUCKDB_ARCHIVE}" -o "${TMP_DIR}/${DUCKDB_ARCHIVE}"
DUCKDB_SHA256=$(curl -fsSL "https://api.github.com/repos/duckdb/duckdb/releases/tags/v${DUCKDB_VERSION}" |
    jq -er --arg asset "${DUCKDB_ARCHIVE}" '.assets[] | select(.name == $asset) | .digest // empty | sub("^sha256:"; "")')
echo "${DUCKDB_SHA256}  ${TMP_DIR}/${DUCKDB_ARCHIVE}" | sha256sum --check --strict

# Install DuckDB CLI
tar -xzf "${TMP_DIR}/${DUCKDB_ARCHIVE}" -C /usr/local/bin/
rm -rf "${TMP_DIR}"
