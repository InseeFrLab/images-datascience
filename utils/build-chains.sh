#!/bin/bash

python3 utils/build-chain.py --chain vscode-python --push || true
python3 utils/build-chain.py --chain vscode-pytorch --gpu --push || true
python3 utils/build-chain.py --chain jupyter-tensorflow --gpu --push || true
python3 utils/build-chain.py --chain rstudio --push || true
sudo shutdown -h now
