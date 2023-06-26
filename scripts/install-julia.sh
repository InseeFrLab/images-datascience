#!/bin/bash
set -e

JULIA_VERSION="1.9.1"

# Install Julia
julia_major_minor=$(echo "${JULIA_VERSION}" | cut -d. -f 1,2)
wget -q "https://julialang-s3.julialang.org/bin/linux/x64/${julia_major_minor}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" -O julia.tar.gz
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
