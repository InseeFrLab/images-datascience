ARG BASE_IMAGE=inseefrlab/base-datascience
FROM $BASE_IMAGE

ARG USERNAME=bobby

# Install miniforge : conda & mamba
RUN curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh && \
    bash Mambaforge-Linux-x86_64.sh -b -p ${HOME}/mambaforge
ENV PATH="${HOME}/mambaforge/bin:${PATH}"

# Create virtual environment
ARG PYTHON_VERSION=3.9
ARG CONDA_ENV_NAME=basesspcloud
COPY environment.yml .
RUN conda create -n {CONDA_ENV_NAME} python=${PYTHON_VERSION} && \
    mamba env update -n {CONDA_ENV_NAME} -f environment.yml

# Activate custom env by default
ENV PATH="${HOME}/local/bin/conda/envs/{CONDA_ENV_NAME}/bin:${PATH}"
RUN echo '. "${HOME}/local/bin/conda/etc/profile.d/conda.sh"' >> ${HOME}/.bashrc && \
    echo "conda activate ${CONDA_ENV_NAME}" >> ${HOME}/.bashrc && \
    echo "export PATH=$PATH" >> ${HOME}/.bashrc
