#!/bin/bash
set -e

/opt/apt-install.sh \
    ca-certificates-java \
    libbz2-dev \
    openjdk-${JAVA_VERSION}-jdk-headless \
    openjdk-${JAVA_VERSION}-jre-headless

if command -v R &>/dev/null; then
    R CMD javareconf
fi
