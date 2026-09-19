#!/bin/bash
set -e

# Build configuration

PUSH=false

DOCKER_BUILD_ARGS=""
[ "$PUSH" = "true" ] && DOCKER_BUILD_ARGS+=" --push"


# Build process

# Versions are kept in sync with .github/workflows/main-workflow.yml by Renovate
PYTHON_VERSION_1="3.13.15"
PYTHON_VERSION_2="3.12.14"
R_VERSION_1="4.6.1"
R_VERSION_2="4.5.3"
SPARK_VERSION="4.1.1"

PYTHON_VERSIONS=("$PYTHON_VERSION_1" "$PYTHON_VERSION_2")
R_VERSIONS=("$R_VERSION_1" "$R_VERSION_2")

for py_ver in "${PYTHON_VERSIONS[@]}"; do
  python3 src/images_datascience/build_chain.py --chain vscode-python --py_version $py_ver $DOCKER_BUILD_ARGS
  python3 src/images_datascience/build_chain.py --chain vscode-pytorch --py_version $py_ver --gpu $DOCKER_BUILD_ARGS
  python3 src/images_datascience/build_chain.py --chain jupyter-pyspark --py_version $py_ver --spark_version $SPARK_VERSION $DOCKER_BUILD_ARGS
done

for r_ver in "${R_VERSIONS[@]}"; do
  python3 src/images_datascience/build_chain.py --chain rstudio --r_version $r_ver $DOCKER_BUILD_ARGS
  python3 src/images_datascience/build_chain.py --chain sparkr --r_version $r_ver --spark_version $SPARK_VERSION $DOCKER_BUILD_ARGS
done

# r-python-julia images are built with only latest versions of R & Python
python3 src/images_datascience/build_chain.py --chain rstudio-r-python-julia --r_version ${R_VERSIONS[0]} --py_version ${PYTHON_VERSIONS[0]} $DOCKER_BUILD_ARGS
python3 src/images_datascience/build_chain.py --chain jupyter-r-python-julia --r_version ${R_VERSIONS[0]} --py_version ${PYTHON_VERSIONS[0]} $DOCKER_BUILD_ARGS
