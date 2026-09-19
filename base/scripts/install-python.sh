#!/bin/bash
set -e

### Install uv

# renovate: datasource=github-releases depName=astral-sh/uv
UV_VERSION="0.12.17"

# Download the official archive and verify its checksum
UV_ARCHIVE="uv-x86_64-unknown-linux-gnu.tar.gz"
UV_URL="https://github.com/astral-sh/uv/releases/download/${UV_VERSION}"
TMP_DIR=$(mktemp -d)
curl -fsSL "${UV_URL}/${UV_ARCHIVE}" -o "${TMP_DIR}/${UV_ARCHIVE}"
curl -fsSL "${UV_URL}/${UV_ARCHIVE}.sha256" -o "${TMP_DIR}/${UV_ARCHIVE}.sha256"
(cd "${TMP_DIR}" && sha256sum --check --strict "${UV_ARCHIVE}.sha256")

# Install uv
tar -xzf "${TMP_DIR}/${UV_ARCHIVE}" -C "${TMP_DIR}"
install -m 0755 "${TMP_DIR}/uv-x86_64-unknown-linux-gnu/uv" "${TMP_DIR}/uv-x86_64-unknown-linux-gnu/uvx" /usr/local/bin/
rm -rf "${TMP_DIR}"


### Install Python with uv prebuilt python binaries

# Install Python in the parent folder of ${PYTHON_DIR} (set in the Dockerfile, and whose bin/ is on the PATH).
# It must not be uv's default location (~/.local/share/uv/python), which `uv pip install --system` ignores,
# nor be reached through a symlink, which breaks the paths uv computes when installing package commands.
# UV_PYTHON_INSTALL_DIR is only set here, so that users' own `uv python` commands never manage this Python.
UV_PYTHON_INSTALL_DIR=$(dirname "${PYTHON_DIR}")
export UV_PYTHON_INSTALL_DIR
export UV_NO_CACHE=1
uv python install "${PYTHON_VERSION}" --no-bin

# uv marks its Pythons as externally managed, which would block `pip install` and `uv pip install --system`
rm "${PYTHON_DIR}/lib/python${PYTHON_VERSION%.*}/EXTERNALLY-MANAGED"

# Checks
python --version
which python

# Upgrade pip
pip install --no-cache-dir --upgrade pip
