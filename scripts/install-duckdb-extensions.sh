#!/bin/bash
set -e

duckdb -c "SET extension_directory='/home/${USERNAME}/.duckdb/extensions'; \
INSTALL httpfs; \
INSTALL aws; \
INSTALL postgres; \
INSTALL spatial; \
"
