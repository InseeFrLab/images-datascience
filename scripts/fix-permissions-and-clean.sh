#!/bin/bash
set -e

# Fix permissions on places where users need write access 
chown -R ${USERNAME}:${GROUPNAME} ${HOME} /usr/local/

# Clean
rm -rf /var/lib/apt/lists/*
