ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

# CPU/GPU
ARG DEVICE_SUFFIX

USER root

COPY conda-env${DEVICE_SUFFIX}.yml .

RUN mamba env update -n base -f conda-env${DEVICE_SUFFIX}.yml && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} && \
    # Clean
    rm conda-env${DEVICE_SUFFIX}.yml && \ 
    mamba clean --all -f -y

USER ${USERNAME}

CMD ["python3"]
