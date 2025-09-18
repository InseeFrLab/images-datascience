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

PACKAGES=("jupyterlab")

if [[ "$ENABLE_JUPYTER_AI_EXTENSION" == "true" ]]; then
    PACKAGES+=("jupyter-ai" "langchain-ollama" "langchain-openai")
fi

if command -v uv &>/dev/null; then
    echo uv pip install --system --no-cache "${PACKAGES[@]}"
else
    echo pip install --no-cache-dir "${PACKAGES[@]}"
fi
