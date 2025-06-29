#!/bin/bash
set -e

# Chown only if needed to avoid duplicate files in Docker layers

find "${HOME}" -not -user "${USERNAME}" -execdir chown --no-dereference "${USERNAME}:${GROUPNAME}" {} \+
find "/opt/" -not -user "${USERNAME}" -execdir chown --no-dereference "${USERNAME}:${GROUPNAME}" {} \+
# Give user permissions on all files in /usr/local except cuda folders
find /usr/local/ \( -path "/usr/local/cuda*" -prune \) -o \
\( -not -user "${USERNAME}" -execdir chown --no-dereference "${USERNAME}:${GROUPNAME}" {} + \)
