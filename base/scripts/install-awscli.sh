#!/bin/bash
set -e

# renovate: datasource=github-tags depName=aws/aws-cli
AWS_CLI_VERSION="2.39.0"

# Download the official archive
AWS_CLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip"
AWS_CLI_ZIP=$(basename "${AWS_CLI_URL}")
TMP_DIR=$(mktemp -d)
curl -fsSL "${AWS_CLI_URL}" -o "${TMP_DIR}/${AWS_CLI_ZIP}"

# PGP signature
AWS_CLI_SIGNATURE_URL="${AWS_CLI_URL}.sig"
curl -fsSL "${AWS_CLI_SIGNATURE_URL}" -o "${TMP_DIR}/${AWS_CLI_ZIP}.sig"

# Install AWS CLI
unzip -q "${TMP_DIR}/${AWS_CLI_ZIP}" -d "${TMP_DIR}"
"${TMP_DIR}/aws/install"
chmod +x /usr/local/bin/aws
rm -rf "${TMP_DIR}"

# Activate autocomplete in the CLI
echo "complete -C '/usr/local/bin/aws_completer' aws" >> ~/.bashrc
