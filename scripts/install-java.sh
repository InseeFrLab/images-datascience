#!/bin/bash
set -e

apt-get update
apt_install \
    ca-certificates-java \
    libbz2-dev \
    openjdk-${JAVA_VERSION}-jdk-headless \
    openjdk-${JAVA_VERSION}-jre-headless

if command -v R; then
    R CMD javareconf
fi
