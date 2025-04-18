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

PYTHON_VERSIONS=("3.12.9" "3.11.12")
R_VERSIONS=("4.4.2" "4.3.3")
SPARK_VERSION=3.5.5

for py_ver in "${PYTHON_VERSIONS[@]}"; do
  python3 utils/build-chain.py --chain vscode-python --py_version $py_ver $CACHE_ARG $PUSH_ARG
  python3 utils/build-chain.py --chain vscode-pytorch --py_version $py_ver --gpu $CACHE_ARG $PUSH_ARG
  python3 utils/build-chain.py --chain vscode-tensorflow --py_version $py_ver --gpu $CACHE_ARG $PUSH_ARG
  python3 utils/build-chain.py --chain jupyter-pyspark --py_version $py_ver --spark_version $SPARK_VERSION $CACHE_ARG $PUSH_ARG
done

for r_ver in "${R_VERSIONS[@]}"; do
  python3 utils/build-chain.py --chain rstudio --r_version $r_ver $CACHE_ARG $PUSH_ARG
  python3 utils/build-chain.py --chain sparkr --r_version $r_ver --spark_version $SPARK_VERSION $CACHE_ARG $PUSH_ARG
done

python3 utils/build-chain.py --chain jupyter-r-python-julia --r_version ${R_VERSIONS[0]} --py_version ${PYTHON_VERSIONS[0]} $CACHE_ARG $PUSH_ARG
