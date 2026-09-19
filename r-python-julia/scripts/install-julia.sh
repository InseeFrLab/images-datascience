#!/bin/bash
set -eo pipefail

# renovate: datasource=github-releases depName=JuliaLang/julia
JULIA_VERSION="1.13.0"

# Download the official archive and verify its checksum
JULIA_ARCHIVE="julia-${JULIA_VERSION}-linux-x86_64.tar.gz"
JULIA_CHECKSUMS="julia-${JULIA_VERSION}.sha256"
TMP_DIR=$(mktemp -d)
curl -fsSL "https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_VERSION%.*}/${JULIA_ARCHIVE}" -o "${TMP_DIR}/${JULIA_ARCHIVE}"
curl -fsSL "https://julialang-s3.julialang.org/bin/checksums/${JULIA_CHECKSUMS}" -o "${TMP_DIR}/${JULIA_CHECKSUMS}"
(cd "${TMP_DIR}" && grep -F "  ${JULIA_ARCHIVE}" "${JULIA_CHECKSUMS}" | sha256sum --check --strict)

# Install Julia
JULIA_DIR="/usr/local/lib/julia"
mkdir -p "${JULIA_DIR}"
tar xzf "${TMP_DIR}/${JULIA_ARCHIVE}" -C "${JULIA_DIR}" --strip-components=1
rm -rf "${TMP_DIR}"

# Put Julia binary in PATH
ln -s "${JULIA_DIR}/bin/julia" /usr/local/bin/julia

# Update and install basic Julia packages
julia -e 'import Pkg; Pkg.update()'
julia -e 'import Pkg; Pkg.add("HDF5")'
