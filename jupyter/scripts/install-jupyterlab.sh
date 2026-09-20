#!/bin/bash
set -e

if command -v uv &>/dev/null; then
    uv pip install --system --no-cache jupyterlab jupyter-ai langchain-openai
else
    pip install --no-cache-dir jupyterlab jupyter-ai langchain-openai
fi

mkdir -p  ${HOME}/.local/share/jupyter/jupyter_ai
