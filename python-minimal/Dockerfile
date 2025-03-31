ARG BASE_IMAGE=inseefrlab/onyxia-base
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ARG PYTHON_VERSION="3.12.9"
ENV PYTHON_VERSION=${PYTHON_VERSION}

# Ensure local Python is preferred over system version
ENV PATH="/usr/local/bin:${PATH}"

USER root

COPY requirements.txt .

# Build Python from source
RUN /opt/install-python.sh && \
    uv pip install --system --no-cache-dir -r requirements.txt && \
    # Re-install system libs that may have been removed by autoremove
    /opt/install-system-libs.sh && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} && \
    # Clean
    rm requirements.txt && \
    rm -rf /var/lib/apt/lists/*

USER 1000

CMD ["python3"]
