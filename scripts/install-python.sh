#!/bin/bash
set -e

# Install Python
wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
tar xzvf Python-${PYTHON_VERSION}.tgz
cd Python-${PYTHON_VERSION}
./configure --enable-optimizations --with-lto
make
sudo make install
sudo ln -fs /usr/local/bin/python3 /usr/bin/python3

# Ensure pip is installed
python3 -m ensurepip --upgrade
