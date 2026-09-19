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

# Install Python outside of uv's default location (~/.local/share/uv/python): `uv pip install --system`
# ignores the Pythons installed there. No cache, and no launchers in ~/.local/bin.
export UV_PYTHON_INSTALL_DIR="/opt/uv-python"
export UV_NO_CACHE=1
uv python install "${PYTHON_VERSION}" --no-bin

# Expose it at a stable path, ${PYTHON_DIR} (set in the Dockerfile), whose bin/ is on the PATH:
# python, python3, python3.X, pip and the commands installed by packages (jupyter, marimo...)
UV_PYTHON_EXECUTABLE=$(uv python find --managed-python "${PYTHON_VERSION}")
ln -s "$(dirname "$(dirname "$(realpath "${UV_PYTHON_EXECUTABLE}")")")" "${PYTHON_DIR}"

# uv marks its Pythons as externally managed, which would block `pip install` and `uv pip install --system`
rm "${PYTHON_DIR}/lib/python${PYTHON_VERSION%.*}/EXTERNALLY-MANAGED"

# Checks
python --version
which python

# Upgrade pip
pip install --no-cache-dir --upgrade pip
