#!/bin/bash

python3 utils/build-chain.py --chain vscode-python --version 3.12.9 --push
python3 utils/build-chain.py --chain rstudio --version 4.4.2 --push
python3 utils/build-chain.py --chain vscode-pytorch --version 3.12.9 --gpu --push
python3 utils/build-chain.py --chain jupyter-tensorflow -- version 3.12.9 --gpu --push
