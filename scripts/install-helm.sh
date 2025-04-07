#!/bin/bash
set -e

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod +x get_helm.sh
./get_helm.sh
rm get_helm.sh

echo 'source <(helm completion bash)' >> ${HOME}/.bashrc
