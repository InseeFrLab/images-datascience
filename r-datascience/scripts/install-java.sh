#!/bin/bash
set -e

apt-get install -y --no-install-recommends \
    ca-certificates-java \
    openjdk-${JAVA_VERSION}-jre-headless \
    openjdk-${JAVA_VERSION}-jdk-headless

JAVA_HOME="/usr/lib/jvm/java-$JAVA_VERSION-openjdk-amd64"

PATH="${JAVA_HOME}/bin:${PATH}"

if command -v R; then
    R CMD javareconf
fi
