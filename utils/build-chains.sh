#!/bin/bash
set -e

# Build configuration

PUSH=false

DOCKER_BUILD_ARGS=""
[ "$PUSH" = "true" ] && DOCKER_BUILD_ARGS+=" --push"


# Build process

PYTHON_VERSIONS=("3.13.5" "3.12.11")
R_VERSIONS=("4.5.1" "4.4.3")
SPARK_VERSION=3.5.5

for py_ver in "${PYTHON_VERSIONS[@]}"; do
  python3 utils/build-chain.py --chain vscode-python --py_version $py_ver $DOCKER_BUILD_ARGS
  python3 utils/build-chain.py --chain vscode-pytorch --py_version $py_ver --gpu $DOCKER_BUILD_ARGS
  python3 utils/build-chain.py --chain jupyter-pyspark --py_version $py_ver --spark_version $SPARK_VERSION $DOCKER_BUILD_ARGS
done

for r_ver in "${R_VERSIONS[@]}"; do
  python3 utils/build-chain.py --chain rstudio --r_version $r_ver $DOCKER_BUILD_ARGS
  python3 utils/build-chain.py --chain sparkr --r_version $r_ver --spark_version $SPARK_VERSION $DOCKER_BUILD_ARGS
done

# tensorflow is not compatible with py3.13
python3 utils/build-chain.py --chain vscode-tensorflow --py_version ${PYTHON_VERSIONS[1]} --gpu $DOCKER_BUILD_ARGS

# r-python-julia images are built with only latest versions of R & Python
python3 utils/build-chain.py --chain rstudio-r-python-julia --r_version ${R_VERSIONS[0]} --py_version ${PYTHON_VERSIONS[0]} $DOCKER_BUILD_ARGS
python3 utils/build-chain.py --chain jupyter-r-python-julia --r_version ${R_VERSIONS[0]} --py_version ${PYTHON_VERSIONS[0]} $DOCKER_BUILD_ARGS
