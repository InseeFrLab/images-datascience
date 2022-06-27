ARG BASE_IMAGE="inseefrlab/base-datascience"
FROM $BASE_IMAGE

ARG USERNAME="bobby"
ENV HOME="/home/${USERNAME}"

USER root

# Install additional system libraries
RUN apt-get -y update && \ 
    apt-get install -y --no-install-recommends \
        build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Quarto
ARG QUARTO_VERSION="0.9.626"
RUN wget "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" && \
    apt-get install "./quarto-${QUARTO_VERSION}-linux-amd64.deb" && \
    rm quarto-${QUARTO_VERSION}-linux-amd64.deb

USER ${USERNAME}

# Install mambaforge : conda & mamba
RUN curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh && \
    bash Mambaforge-Linux-x86_64.sh -b -p ${HOME}/mambaforge && \
    rm Mambaforge-Linux-x86_64.sh
ENV PATH="${HOME}/mambaforge/bin:${PATH}"

# Create custom Conda env
ARG PYTHON_VERSION="3.9"
ARG CONDA_ENV_NAME="basesspcloud"
COPY environment.yml .
RUN conda create -n ${CONDA_ENV_NAME} python=${PYTHON_VERSION} && \
    mamba env update -n ${CONDA_ENV_NAME} -f environment.yml && \
    mamba install -y pytorch torchvision torchaudio cudatoolkit=11.3 -c pytorch && \
    rm environment.yml

# Activate custom Conda env by default
ENV PATH="${HOME}/mambaforge/envs/${CONDA_ENV_NAME}/bin:${PATH}"
RUN echo ". ${HOME}/mambaforge/etc/profile.d/conda.sh" >> ${HOME}/.bashrc && \
    echo "conda activate ${CONDA_ENV_NAME}" >> ${HOME}/.bashrc && \
    echo "export PATH=$PATH" >> ${HOME}/.bashrc

CMD ["python3"]
