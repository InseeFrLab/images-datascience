#!/bin/bash
set -e

# Build configuration

PUSH=false

DOCKER_BUILD_ARGS=""
[ "$PUSH" = "true" ] && DOCKER_BUILD_ARGS+=" --push"


# Build process

# Maintained versions (PYTHON_VERSION_1/2, R_VERSION_1/2, SPARK_VERSION)
# shellcheck source=versions.env
source "$(dirname "$0")/../versions.env"

PYTHON_VERSIONS=("$PYTHON_VERSION_1" "$PYTHON_VERSION_2")
R_VERSIONS=("$R_VERSION_1" "$R_VERSION_2")

for py_ver in "${PYTHON_VERSIONS[@]}"; do
  python3 utils/build_chain.py --chain vscode-python --py_version $py_ver $DOCKER_BUILD_ARGS
  python3 utils/build_chain.py --chain vscode-pytorch --py_version $py_ver --gpu $DOCKER_BUILD_ARGS
  python3 utils/build_chain.py --chain jupyter-pyspark --py_version $py_ver --spark_version $SPARK_VERSION $DOCKER_BUILD_ARGS
done

for r_ver in "${R_VERSIONS[@]}"; do
  python3 utils/build_chain.py --chain rstudio --r_version $r_ver $DOCKER_BUILD_ARGS
  python3 utils/build_chain.py --chain sparkr --r_version $r_ver --spark_version $SPARK_VERSION $DOCKER_BUILD_ARGS
done

# r-python-julia images are built with only latest versions of R & Python
python3 utils/build_chain.py --chain rstudio-r-python-julia --r_version ${R_VERSIONS[0]} --py_version ${PYTHON_VERSIONS[0]} $DOCKER_BUILD_ARGS
python3 utils/build_chain.py --chain jupyter-r-python-julia --r_version ${R_VERSIONS[0]} --py_version ${PYTHON_VERSIONS[0]} $DOCKER_BUILD_ARGS
