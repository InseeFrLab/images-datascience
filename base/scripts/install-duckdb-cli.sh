#!/bin/bash
set -e

# Install DuckDB CLI

ARCH=$(uname -m)

case $ARCH in
    "x86_64")
        FILENAME="duckdb_cli-linux-amd64.zip"
        ;;
    "aarch64")
        FILENAME="duckdb_cli-linux-arm64.zip"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

wget -q https://github.com/duckdb/duckdb/releases/latest/download/$FILENAME
unzip $FILENAME -d /usr/local/bin/

# Clean
rm $FILENAME
