#!/bin/bash
set -e

source ./utils.sh

apt_install \
    libglpk40 \
    libpq-dev \
    libzmq3-dev
