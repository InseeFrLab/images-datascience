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
