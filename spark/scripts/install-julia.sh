#!/bin/bash
set -e

JULIA_VERSION="1.10.0"

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
julia_major_minor=$(echo "${JULIA_VERSION}" | cut -d. -f 1,2)
wget -q "https://julialang-s3.julialang.org/bin/linux/${ARCHITECTURE}/${julia_major_minor}/julia-${JULIA_VERSION}-linux-${ARCH}.tar.gz" -O julia.tar.gz
mkdir "${JULIA_DIR}"
tar xzf julia.tar.gz -C "${JULIA_DIR}" --strip-components=1
rm julia.tar.gz

# Show Julia where conda libraries are
if command -v mamba ; then \
    mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"${MAMBA_DIR}/lib\")" >> /etc/julia/juliarc.jl; \
fi

# Update and install basic Julia packages
julia -e 'import Pkg; Pkg.update()'
julia -e 'import Pkg; Pkg.add("HDF5")'
