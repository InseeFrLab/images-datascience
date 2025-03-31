ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

USER root

RUN if ! [[ -z "${CUDA_VERSION}" ]]; then \
        # CUDA support
        pip3 install torch torchvision torchaudio; \
    else \
        # CPU only
        pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu; \
    fi && \
    # Fix permissions and clean
    /opt/fix-permissions-and-clean.sh

USER 1000

CMD ["python3"]
