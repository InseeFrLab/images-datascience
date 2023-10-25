#!/bin/bash
set -e

wget -q https://github.com/duckdb/duckdb/releases/latest/download/duckdb_cli-linux-amd64.zip
unzip duckdb_cli-linux-amd64.zip -d /usr/local/bin/
rm duckdb_cli-linux-amd64.zip
