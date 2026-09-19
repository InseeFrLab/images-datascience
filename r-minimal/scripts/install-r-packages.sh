#!/bin/bash
set -e

# Install some standard R packages
install2.r --ncpus -1 --error \
    devtools \
    lintr \
    remotes \
    renv
