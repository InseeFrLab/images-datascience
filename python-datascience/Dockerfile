ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG USERNAME="bobby"
ENV HOME="/home/${USERNAME}"

USER root

# Install additional system libraries
RUN apt-get -y update && \ 
    apt-get install -y --no-install-recommends \
        build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${USERNAME}

# Install mambaforge & create custom Conda environment
ARG MAMBAFORGE_VERSION="4.12.0-2"
ARG MAMBAFORGE_DIR="${HOME}/mambaforge"
ARG CONDA_ENV_NAME="basesspcloud"
ARG PYTHON_VERSION="3.9"
ARG DEVICE_SUFFIX
ENV PATH="${HOME}/mambaforge/envs/${CONDA_ENV_NAME}/bin:${MAMBAFORGE_DIR}/bin:${PATH}"
COPY environment.yml .
RUN wget --no-hsts --quiet https://github.com/conda-forge/miniforge/releases/download/${MAMBAFORGE_VERSION}/Mambaforge-${MAMBAFORGE_VERSION}-Linux-x86_64.sh -O /tmp/mambaforge.sh && \
    # Install mambaforge
    /bin/bash /tmp/mambaforge.sh -b -p ${MAMBAFORGE_DIR} && \
    rm /tmp/mambaforge.sh && \
    # Create custom Conda environment
    conda create -n ${CONDA_ENV_NAME} python=${PYTHON_VERSION} && \
    # Install data science packages
    mamba env update -n ${CONDA_ENV_NAME} -f lib-datascience.yml && \
    # Install deep learning packages
    mamba env update -n ${CONDA_ENV_NAME} -f lib-dl${DEVICE_SUFFIX}.yml && \
    # Activate custom Conda env by default in shell
    echo ". ${MAMBAFORGE_DIR}/etc/profile.d/conda.sh && conda activate ${CONDA_ENV_NAME}" >> ${HOME}/.bashrc && \
    # Clean
    rm environment.yml && \ 
    find ${MAMBAFORGE_DIR} -follow -type f -name '*.a' -delete && \
    find ${MAMBAFORGE_DIR} -follow -type f -name '*.pyc' -delete && \
    conda clean -afy

CMD ["python3"]
