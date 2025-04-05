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
    # Install Python packages
    uv pip install --system --no-cache -r requirements.txt && \
    # Fix user permissions
    /opt/fix-user-permissions.sh && \
    # Clean
    /opt/clean.sh requirements.txt

USER 1000

CMD ["python3"]
