#!/bin/bash
set -e

ARCH=$(uname -m)

case $ARCH in
    "x86_64")
        ARCHITECTURE="x64"
        ;;
    "aarch64")
        ARCHITECTURE="aarch64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Install Julia
JULIA_LATEST_VERSION=$(curl --silent "https://api.github.com/repos/JuliaLang/julia/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")' | sed 's/^v//')
julia_major_minor=$(echo "${JULIA_LATEST_VERSION}" | cut -d. -f 1,2)
wget -q "https://julialang-s3.julialang.org/bin/linux/${ARCHITECTURE}/${julia_major_minor}/julia-${JULIA_LATEST_VERSION}-linux-${ARCH}.tar.gz" -O julia.tar.gz
mkdir "${JULIA_DIR}"
tar xzf julia.tar.gz -C "${JULIA_DIR}" --strip-components=1
rm julia.tar.gz

# Update and install basic Julia packages
julia -e 'import Pkg; Pkg.update()'
julia -e 'import Pkg; Pkg.add("HDF5")'
