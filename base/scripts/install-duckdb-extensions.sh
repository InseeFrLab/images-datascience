#!/bin/bash
set -e

duckdb -c "
INSTALL httpfs; \
INSTALL aws; \
INSTALL postgres; \
INSTALL spatial; \
"
