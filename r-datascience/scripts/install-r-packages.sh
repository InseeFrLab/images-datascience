#!/bin/bash
set -e

# Install useful R packages for data science
install2.r --ncpus -1 --error \
    arrow \
    aws.s3 \
    DBI \
    duckdb \
    paws \
    quarto \
    RPostgres \
    RPostgreSQL \
    tidyverse

# Install package for data science not present in CRAN
NOT_CRAN=true install2.R --ncpus 1 --error --no-multiarch \
    --repos "https://community.r-multiverse.org" "polars"
