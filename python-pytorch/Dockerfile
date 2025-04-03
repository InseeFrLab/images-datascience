ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

USER root

RUN if ! [[ -z "${CUDA_VERSION}" ]]; then \
        # CUDA support
        uv pip install --system --no-cache torch torchvision torchaudio; \
    else \
        # CPU only
        uv pip install --system --no-cache torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu; \
    fi && \
    # Give user ownership
    /opt/make_user_owner.sh && \
    # Clean
    /opt/clean.sh

USER 1000

CMD ["python3"]
