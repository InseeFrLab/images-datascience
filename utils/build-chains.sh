#!/bin/bash

LOGFILE=$(printf '%(%Y-%m-%d_%H:%M:%S)T\n' -1).log

python3 utils/build-chain.py --chain vscode-python --push || true
python3 utils/build-chain.py --chain rstudio --push || true
python3 utils/build-chain.py --chain jupyter-r-python-julia --push || true
python3 utils/build-chain.py --chain vscode-pytorch --gpu --push || true
python3 utils/build-chain.py --chain jupyter-tensorflow --gpu --push || true

mc cp nohup.out s3/projet-onyxia/build-images-datascience/$LOGFILE

sudo shutdown -h now
