ARG BASE_IMAGE=inseefrlab/onyxia-base
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ARG PYTHON_VERSION="3.12.10"
ENV PYTHON_VERSION=${PYTHON_VERSION}

USER root

# Build Python from source
RUN /opt/install-python.sh

# Install Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} && \
    # Clean
    rm -rf /var/lib/apt/lists/*

USER 1000

CMD ["python3"]
