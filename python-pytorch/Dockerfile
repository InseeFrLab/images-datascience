ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER root

COPY conda-env.yml .

RUN if [ -n "$CUDA_VERSION" ]; then \
        cuda_major=`echo $CUDA_VERSION | cut -d. -f1`; \
        cuda_minor=`echo $CUDA_VERSION | cut -d. -f2`; \
        echo "  - pytorch::magma-cuda${cuda_major}${cuda_minor}" >> conda-env.yml; \
    fi && \
    mamba env update -n base -f conda-env.yml && \
    git clone --recursive https://github.com/pytorch/pytorch && \
    cd pytorch && \
    export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"} && \
    python setup.py develop && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} && \
    # Clean
    rm conda-env${DEVICE_SUFFIX}.yml && \ 
    mamba clean --all -f -y

USER 1000

CMD ["python3"]
