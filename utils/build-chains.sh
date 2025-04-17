#!/bin/bash
set -e

NO_CACHE=false
PUSH=false

PUSH_ARG=""
if [ "$PUSH" = "true" ]; then
  PUSH_ARG="--push"
fi

CACHE_ARG=""
if [ "$NO_CACHE" = "true" ]; then
  CACHE_ARG="--no_cache"
fi

PYTHON_VERSION=3.11.12
R_VERSION=4.5.0
SPARK_VERSION=3.5.5

# Commands
python3 utils/build-chain.py --chain vscode-python --py_version $PYTHON_VERSION $CACHE_ARG $PUSH_ARG
python3 utils/build-chain.py --chain rstudio --r_version $R_VERSION $CACHE_ARG $PUSH_ARG
python3 utils/build-chain.py --chain jupyter-r-python-julia --r_version $R_VERSION $CACHE_ARG --py_version $PYTHON_VERSION $PUSH_ARG
python3 utils/build-chain.py --chain vscode-pytorch --py_version $PYTHON_VERSION $CACHE_ARG --gpu $PUSH_ARG
python3 utils/build-chain.py --chain vscode-tensorflow --py_version $PYTHON_VERSION $CACHE_ARG --gpu $PUSH_ARG
python3 utils/build-chain.py --chain jupyter-pyspark --py_version $PYTHON_VERSION $CACHE_ARG --spark_version $SPARK_VERSION $PUSH_ARG
