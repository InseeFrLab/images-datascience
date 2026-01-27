#!/bin/bash
set -e

function apt_install() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            apt-get update
        fi
        apt-get install -y --no-install-recommends "$@"
    fi
}

if command -v uv &>/dev/null; then
    uv pip install --system --no-cache jupyterlab jupyter-ai langchain-openai
else
    pip install --no-cache-dir jupyterlab jupyter-ai langchain-openai
fi

mkdir -p  ${HOME}/.local/share/jupyter
