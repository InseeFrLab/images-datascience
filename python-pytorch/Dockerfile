ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

USER root

RUN if ! [[ -z "${CUDA_VERSION}" ]]; then \
        # CUDA support
        REQUIREMENTS_FILE='requirements-gpu.txt'
    else \
        # CPU only
        REQUIREMENTS_FILE='requirements-cpu.txt'
    fi && \
    uv pip install --system --no-cache -r ${REQUIREMENTS_FILE} && \
    # Fix user permissions
    /opt/fix-permissions-python.sh && \
    # Clean
    /opt/clean.sh

USER 1000

CMD ["python3"]
