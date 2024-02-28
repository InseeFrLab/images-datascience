#!/bin/bash
set -e

duckdb -c "SET extension_directory=\"${HOME}/.duckdb/extensions\";"
duckdb -c "INSTALL httpfs;"
duckdb -c "INSTALL aws;"
duckdb -c "INSTALL postgres;"
duckdb -c "INSTALL spatial;"
