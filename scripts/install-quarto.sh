#!/bin/bash
set -e

# Install latest version of quarto
QUARTO_DL_URL=$(wget -qO- https://quarto.org/docs/download/_download.json | grep -oP '(?<=\"download_url\":\s\")https.*linux-amd64.deb')
wget -q ${QUARTO_DL_URL} -O quarto.deb
dpkg -i quarto.deb
quarto check install
rm quarto.deb

# Install TinyTeX to enable rendering PDF documents via quarto
quarto install tinytex --update-path
