#!/bin/bash
set -e

duckdb -c << EOF 
SET extension_directory=\"${HOME}/.duckdb/extensions\"; 
INSTALL httpfs; 
INSTALL aws; 
INSTALL postgres; 
INSTALL spatial;
EOF
