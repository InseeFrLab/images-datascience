ARG BASE_IMAGE=inseefrlab/onyxia-base
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ARG PYTHON_VERSION="3.12.6"
ENV PYTHON_VERSION=${PYTHON_VERSION}

ENV CONDA_DIR="/opt/conda"
ENV PATH="${CONDA_DIR}/bin:${PATH}"

USER root

COPY conda-env.yml .

RUN /opt/install-conda.sh && \
    # Set specified Python version in base Conda env
    conda install python=="${PYTHON_VERSION}" && \
    # Pin Python version to prevent Conda from upgrading it
    touch ${CONDA_DIR}/conda-meta/pinned && \
    echo "python==${PYTHON_VERSION}" >> ${CONDA_DIR}/conda-meta/pinned && \
    # Install essential Python packages
    conda env update -n base -f conda-env.yml && \
    # Install duckdb extensions
    conda run -n base python /opt/install-duckdb-extensions.py && \
    # Activate custom Conda env by default in shell
    echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate" >> ${HOME}/.bashrc && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${CONDA_DIR} && \
    # Clean
    rm conda-env.yml && \ 
    conda clean --all -f -y && \
    rm -rf /var/lib/apt/lists/*

USER 1000

CMD ["python3"]
