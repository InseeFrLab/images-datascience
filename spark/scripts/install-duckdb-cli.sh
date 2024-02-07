#!/bin/bash
set -e

ARCH=$(uname -m)

case $ARCH in
    "x86_64")
        FILENAME="duckdb_cli-linux-amd64.zip"
        ;;
    "aarch64")
        FILENAME="duckdb_cli-linux-aarch64.zip"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

wget -q https://github.com/duckdb/duckdb/releases/latest/download/$FILENAME
unzip $FILENAME -d /usr/local/bin/
rm $FILENAME
duckdb -c "SET extension_directory=\"${HOME}\" ; INSTALL httpfs; INSTALL aws;"
