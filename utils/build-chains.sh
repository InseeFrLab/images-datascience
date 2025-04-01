#!/bin/bash

python3 utils/build-chain.py --chain vscode-python --push
python3 utils/build-chain.py --chain vscode-pytorch --gpu --push
python3 utils/build-chain.py --chain jupyter-tensorflow --gpu --push
python3 utils/build-chain.py --chain rstudio --push
