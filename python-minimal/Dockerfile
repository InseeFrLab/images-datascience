ARG BASE_IMAGE=inseefrlab/onyxia-base
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ARG PYTHON_VERSION="3.11.6"
ENV PYTHON_VERSION=${PYTHON_VERSION}

ENV MAMBA_DIR="/opt/mamba"
ENV PATH="${MAMBA_DIR}/bin:${PATH}"

USER root

COPY conda-env.yml .

RUN wget -q "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" -O miniforge.sh && \
    # Install mambaforge latest version
    /bin/bash miniforge.sh -b -p "${MAMBA_DIR}"
    # Set specified Python version in base Conda env

RUN mamba install python=="${PYTHON_VERSION}"

USER 1000

CMD ["python3"]
