#!/bin/bash
set -e

apt-get update
apt-get install -y --no-install-recommends \
    ca-certificates-java \
    libbz2-dev \
    openjdk-${JAVA_VERSION}-jre-headless \
    openjdk-${JAVA_VERSION}-jdk-headless

if command -v R; then
    R CMD javareconf
fi
