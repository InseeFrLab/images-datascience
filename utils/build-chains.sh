#!/bin/bash

LOGFILE=$(printf '%(%Y-%m-%d_%H:%M:%S)T\n' -1).log

python3 utils/build-chain.py --chain vscode-python --version 3.12.9 --push
python3 utils/build-chain.py --chain rstudio --version 4.4.2 --push
# python3 utils/build-chain.py --chain vscode-pytorch --version 3.12.9 --gpu --push
# python3 utils/build-chain.py --chain jupyter-tensorflow -- version 3.12.9 --gpu --push

mc cp nohup.out s3/projet-onyxia/build-images-datascience/$LOGFILE

shutdown -h now
