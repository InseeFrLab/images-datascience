ARG BASE_IMAGE=inseefrlab/onyxia-python-datascience
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

# CPU/GPU
ARG DEVICE_SUFFIX

USER root

COPY environment/lib-datascience.yml .
COPY environment/lib-dl${DEVICE_SUFFIX}.yml .

RUN cat lib-datascience.yml lib-dl${DEVICE_SUFFIX}.yml > env-specs.yml && \
    # Install datascience packages
    mamba env update -n base -f env-specs.yml && \
    # Install Quarto latest version
    QUARTO_DL_URL=$(wget -qO- https://quarto.org/docs/download/_download.json | grep -oP '(?<=\"download_url\":\s\")https.*linux-amd64.deb') && \
    wget -q ${QUARTO_DL_URL} -O quarto.deb && \
    dpkg -i quarto.deb && \
    quarto check install && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${MAMBA_DIR} && \
    # Clean
    rm lib-datascience.yml lib-dl${DEVICE_SUFFIX}.yml env-specs.yml quarto.deb && \ 
    mamba clean --all -f -y

USER ${USERNAME}

CMD ["python3"]
