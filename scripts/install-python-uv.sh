#!/bin/bash
set -e

# Install Python
uv python install ${PYTHON_VERSION} --default --preview
