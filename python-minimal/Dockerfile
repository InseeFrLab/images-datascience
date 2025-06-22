ARG BASE_IMAGE=inseefrlab/onyxia-base
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ARG PYTHON_VERSION="3.12.11"
ENV PYTHON_VERSION=${PYTHON_VERSION}

# Ensure local Python is preferred over system version
ENV PATH="/usr/local/bin:${PATH}"

USER root

COPY --chmod=0755 scripts/ /opt/
COPY requirements.txt .

# Build Python from source
RUN /opt/install-python.sh && \
    # Install Python packages
    uv pip install --system --no-cache -r requirements.txt && \
    # Install duckdb extensions
    python /opt/install-duckdb-extensions.py && \
    # Fix user permissions
    /opt/fix-user-permissions.sh && \
    # Clean
    /opt/clean.sh requirements.txt

USER 1000

CMD ["python"]
