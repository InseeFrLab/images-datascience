#!/bin/bash
set -e

# Chown only if needed to avoid duplicate files in Docker layers
find "${HOME}" -not -user "${USERNAME}" -execdir chown --no-dereference "${USERNAME}:${GROUPNAME}" {} \+
find /usr/local/ -not -user "${USERNAME}" -execdir chown --no-dereference "${USERNAME}:${GROUPNAME}" {} \+
find /opt/ -not -user "${USERNAME}" -execdir chown --no-dereference "${USERNAME}:${GROUPNAME}" {} \+
