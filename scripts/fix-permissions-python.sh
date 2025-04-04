#!/bin/bash
set -e

chown -R ${USERNAME}:${GROUPNAME} /usr/local/lib/python${PYTHON_VERSION%.*}/site-packages/
chown -R ${USERNAME}:${GROUPNAME} ${HOME}/.cache/
