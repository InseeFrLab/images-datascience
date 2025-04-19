#!/bin/bash
set -e

# Get Julia
JULIA_LATEST_VERSION=$(curl --silent "https://api.github.com/repos/JuliaLang/julia/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")' | sed 's/^v//')
julia_major_minor=$(echo "${JULIA_LATEST_VERSION}" | cut -d. -f 1,2)
wget -q "https://julialang-s3.julialang.org/bin/linux/x64/${julia_major_minor}/julia-${JULIA_LATEST_VERSION}-linux-x86_64.tar.gz" -O julia.tar.gz

# Install Julia
JULIA_DIR="/usr/local/lib/julia"
mkdir -p "${JULIA_DIR}"
tar xzf julia.tar.gz -C "${JULIA_DIR}" --strip-components=1
rm julia.tar.gz

# Put Julia binary in PATH
ln -s "${JULIA_DIR}/bin/julia" /usr/local/bin/julia

# Update and install basic Julia packages
julia -e 'import Pkg; Pkg.update()'
julia -e 'import Pkg; Pkg.add("HDF5")'
