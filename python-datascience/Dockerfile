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
    # Install quarto
    chmod +x /opt/install-quarto.sh && \
    /opt/install-quarto.sh && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${MAMBA_DIR} && \
    # Clean
    rm lib-datascience.yml lib-dl${DEVICE_SUFFIX}.yml env-specs.yml && \ 
    mamba clean --all -f -y

USER ${USERNAME}

CMD ["python3"]
