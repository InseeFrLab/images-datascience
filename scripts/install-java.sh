#!/bin/bash
set -e

apt-get install -y --no-install-recommends \
    ca-certificates-java \
    openjdk-${JAVA_VERSION}-jre-headless \
    openjdk-${JAVA_VERSION}-jdk-headless \
    libbz2-dev # for jdk

if command -v R; then
    R CMD javareconf
fi
