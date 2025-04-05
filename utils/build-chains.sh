#!/bin/bash
set -e

python3 utils/build-chain.py --chain vscode-python --py_version 3.12.9 --push
python3 utils/build-chain.py --chain rstudio --r_version 4.4.2 --push
python3 utils/build-chain.py --chain vscode-pytorch --py_version 3.12.9 --gpu --push
python3 utils/build-chain.py --chain vscode-tensorflow --py_version 3.12.9 --gpu --push
python3 utils/build-chain.py --chain jupyter-r-python-julia --r_version 4.4.2 --py_version 3.12.9 --push
python3 utils/build-chain.py --chain jupyter-pyspark --py_version 3.12.9 --spark_version 3.5.5 --push
