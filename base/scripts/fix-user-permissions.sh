#!/bin/bash
set -e

# Chown only if needed to avoid duplicate files in Docker layers

# Give user permission on all files in HOME
find "${HOME}" -not -user "${USERNAME}" -execdir chown --no-dereference "${USERNAME}:${GROUPNAME}" {} \+

# Give user permissions on all files in /usr/local except cuda folders
find /usr/local/ \( -path "/usr/local/cuda*" -prune \) -o \
\( -not -user "${USERNAME}" -execdir chown --no-dereference "${USERNAME}:${GROUPNAME}" {} + \)
