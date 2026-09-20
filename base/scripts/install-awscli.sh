#!/bin/bash
set -e

# renovate: datasource=github-tags depName=aws/aws-cli
AWS_CLI_VERSION="2.36.49"

# Download the official archive and its PGP signature
AWS_CLI_ZIP="awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip"
TMP_DIR=$(mktemp -d)
curl -fsSL "https://awscli.amazonaws.com/${AWS_CLI_ZIP}" -o "${TMP_DIR}/${AWS_CLI_ZIP}"
curl -fsSL "https://awscli.amazonaws.com/${AWS_CLI_ZIP}.sig" -o "${TMP_DIR}/${AWS_CLI_ZIP}.sig"

# Install AWS CLI
unzip -q "${TMP_DIR}/${AWS_CLI_ZIP}" -d "${TMP_DIR}"
"${TMP_DIR}/aws/install"
chmod +x /usr/local/bin/aws
rm -rf "${TMP_DIR}"

# Activate autocomplete in the CLI
echo "complete -C '/usr/local/bin/aws_completer' aws" >> ~/.bashrc
