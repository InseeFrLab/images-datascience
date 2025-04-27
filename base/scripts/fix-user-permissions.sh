#!/bin/bash
set -e

# Give user permission on all files in HOME
find "${HOME}" -not -user "${USERNAME}" -execdir chown --no-dereference "${USERNAME}:${GROUPNAME}" {} \+

# Give user permissions on all files in /usr/local except cuda folders
find /usr/local/ \( -path "/usr/local/cuda*" -prune \) -o \
\( -not -user "${USERNAME}" -execdir chown --no-dereference "${USERNAME}:${GROUPNAME}" {} + \)

# Give user permission on all files in ROOT_PROJECT_DIRECTORY if it exists
# This variable is used in our charts
if [[ -z "${ROOT_PROJECT_DIRECTORY}" ]]; then
  find "${ROOT_PROJECT_DIRECTORY}" -not -user "${USERNAME}" -execdir chown --no-dereference "${USERNAME}:${GROUPNAME}" {} \+
fi
