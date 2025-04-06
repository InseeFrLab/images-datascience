#!/bin/bash
set -e

PUSH=true

PUSH_ARG=""
if [ "$PUSH" = "true" ]; then
  PUSH_ARG="--push"
fi

echo $PUSH_ARG

# Commands
python3 utils/build-chain.py --chain vscode-python --py_version 3.12.9 $PUSH_ARG
python3 utils/build-chain.py --chain rstudio --r_version 4.4.2 $PUSH_ARG
python3 utils/build-chain.py --chain vscode-pytorch --py_version 3.12.9 --gpu $PUSH_ARG
python3 utils/build-chain.py --chain vscode-tensorflow --py_version 3.12.9 --gpu $PUSH_ARG
python3 utils/build-chain.py --chain jupyter-r-python-julia --r_version 4.4.2 --py_version 3.12.9 $PUSH_ARG
python3 utils/build-chain.py --chain jupyter-pyspark --py_version 3.12.9 --spark_version 3.5.5 $PUSH_ARG
