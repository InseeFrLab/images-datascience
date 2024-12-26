ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

USER root

COPY conda-env.yml .

RUN ls -larth /opt/
RUN conda env update -n base -f conda-env.yml && \
    # Install Quarto latest version
    /opt/install-quarto.sh && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${CONDA_DIR} ${JULIA_DIR} && \
    # Clean
    rm conda-env.yml && \ 
    conda clean --all -f -y && \
    rm -rf /var/lib/apt/lists/*

USER 1000

CMD ["python3"]
