ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ENV JULIA_DIR="/opt/julia"
ENV PATH="${JULIA_DIR}/bin:${PATH}"

USER root

COPY conda-env.yml .

RUN ls -larth /opt/
RUN conda env update -n base -f conda-env.yml && \
    # Install Python packages not available on conda-forge
    pip3 install opencv-python-headless && \
    # Install Julia
    /opt/install-julia.sh && \
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
