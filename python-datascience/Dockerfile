ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG USERNAME="bobby"
USER ${USERNAME}

ARG MAMBAFORGE_VERSION="4.12.0-2"
ARG MAMBAFORGE_DIR="${HOME}/mambaforge"
ARG CONDA_ENV_NAME="basesspcloud"
ARG PYTHON_VERSION="3.9"
ARG DEVICE_SUFFIX

ENV PATH="${HOME}/mambaforge/envs/${CONDA_ENV_NAME}/bin:${MAMBAFORGE_DIR}/bin:${PATH}"

COPY lib-datascience.yml .
COPY lib-dl${DEVICE_SUFFIX}.yml .

RUN wget --no-hsts --quiet https://github.com/conda-forge/miniforge/releases/download/${MAMBAFORGE_VERSION}/Mambaforge-${MAMBAFORGE_VERSION}-Linux-x86_64.sh -O /tmp/mambaforge.sh && \
    # Install mambaforge
    /bin/bash /tmp/mambaforge.sh -b -p ${MAMBAFORGE_DIR} && \
    # Create custom Conda environment
    conda create -n ${CONDA_ENV_NAME} python=${PYTHON_VERSION} && \
    # Merge Conda env files to install DL libraries for CPU or GPU
    cat lib-datascience.yml lib-dl${DEVICE_SUFFIX}.yml > env-specs.yml && \
    # Install packages
    mamba env update -n ${CONDA_ENV_NAME} -f env-specs.yml && \
    # Activate custom Conda env by default in shell
    echo ". ${MAMBAFORGE_DIR}/etc/profile.d/conda.sh && conda activate ${CONDA_ENV_NAME}" >> ${HOME}/.bashrc && \
    # Clean
    rm /tmp/mambaforge.sh && \
    rm lib-datascience.yml lib-dl${DEVICE_SUFFIX}.yml env-specs.yml && \ 
    find ${MAMBAFORGE_DIR} -follow -type f -name '*.a' -delete && \
    find ${MAMBAFORGE_DIR} -follow -type f -name '*.pyc' -delete && \
    mamba clean --all -f -y

CMD ["python3"]
