#!/bin/bash
set -e

# Install Conda via Miniforge
wget -q "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" -O miniforge.sh
chmod +x miniforge.sh
./miniforge.sh -b -p "${CONDA_DIR}"
rm miniforge.sh
