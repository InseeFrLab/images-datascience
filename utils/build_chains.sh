#!/bin/bash
set -e

# Build configuration

PUSH=false

DOCKER_BUILD_ARGS=""
[ "$PUSH" = "true" ] && DOCKER_BUILD_ARGS+=" --push"


# Build process

# Load maintained versions
source "versions.env"

PYTHON_VERSIONS=("$PYTHON_VERSION_1" "$PYTHON_VERSION_2")
R_VERSIONS=("$R_VERSION_1" "$R_VERSION_2")

for py_ver in "${PYTHON_VERSIONS[@]}"; do
  uv run python3 -m utils.build_chain --chain vscode-python --py_version $py_ver $DOCKER_BUILD_ARGS
  uv run python3 -m utils.build_chain --chain vscode-pytorch --py_version $py_ver --gpu $DOCKER_BUILD_ARGS
  uv run python3 -m utils.build_chain --chain jupyter-pyspark --py_version $py_ver --spark_version $SPARK_VERSION $DOCKER_BUILD_ARGS
done

for r_ver in "${R_VERSIONS[@]}"; do
  uv run python3 -m utils.build_chain --chain rstudio --r_version $r_ver $DOCKER_BUILD_ARGS
  uv run python3 -m utils.build_chain --chain sparkr --r_version $r_ver --spark_version $SPARK_VERSION $DOCKER_BUILD_ARGS
done

# r-python-julia images are built with only latest version of R & Python
uv run python3 -m utils.build_chain --chain vscode-r-python-julia --r_version ${R_VERSIONS[0]} --py_version ${PYTHON_VERSIONS[0]} $DOCKER_BUILD_ARGS
