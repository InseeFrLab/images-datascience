#!/bin/bash
set -eo pipefail

# renovate: datasource=github-releases depName=duckdb/duckdb
DUCKDB_VERSION="1.5.5"

# Download the GitHub archive and verify its checksum
DUCKDB_ZIP="duckdb_cli-linux-amd64.zip"
TMP_DIR=$(mktemp -d)
curl -fsSL "https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/${DUCKDB_ZIP}" -o "${TMP_DIR}/${DUCKDB_ZIP}"
DUCKDB_SHA256=$(curl -fsSL "https://api.github.com/repos/duckdb/duckdb/releases/tags/v${DUCKDB_VERSION}" |
    jq -er --arg asset "${DUCKDB_ZIP}" '.assets[] | select(.name == $asset) | .digest // empty | sub("^sha256:"; "")')
echo "${DUCKDB_SHA256}  ${TMP_DIR}/${DUCKDB_ZIP}" | sha256sum --check --strict

# Install DuckDB CLI
unzip -q "${TMP_DIR}/${DUCKDB_ZIP}" -d /usr/local/bin/
rm -rf "${TMP_DIR}"
