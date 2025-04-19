#!/bin/bash
set -e

PUSH=true
NO_CACHE=false

DOCKER_BUILD_ARGS=""
[ "$PUSH" = "true" ] && DOCKER_BUILD_ARGS+=" --push"
[ "$NO_CACHE" = "true" ] && DOCKER_BUILD_ARGS+=" --no_cache"

PYTHON_VERSIONS=("3.12.9" "3.11.12")
R_VERSIONS=("4.5.0" "4.4.3")
SPARK_VERSION=3.5.5

for py_ver in "${PYTHON_VERSIONS[@]}"; do
  python3 utils/build-chain.py --chain vscode-python --py_version $py_ver $DOCKER_BUILD_ARGS
  python3 utils/build-chain.py --chain vscode-pytorch --py_version $py_ver --gpu $DOCKER_BUILD_ARGS
  python3 utils/build-chain.py --chain vscode-tensorflow --py_version $py_ver --gpu $DOCKER_BUILD_ARGS
  python3 utils/build-chain.py --chain jupyter-pyspark --py_version $py_ver --spark_version $SPARK_VERSION --no_test $DOCKER_BUILD_ARGS
done

for r_ver in "${R_VERSIONS[@]}"; do
  python3 utils/build-chain.py --chain rstudio --r_version $r_ver $DOCKER_BUILD_ARGS
  python3 utils/build-chain.py --chain sparkr --r_version $r_ver --spark_version $SPARK_VERSION --no_test $DOCKER_BUILD_ARGS
done

python3 utils/build-chain.py --chain jupyter-r-python-julia --r_version ${R_VERSIONS[0]} --py_version ${PYTHON_VERSIONS[0]} $DOCKER_BUILD_ARGS
