ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

USER root

# Install Python packages
COPY requirements.txt .
RUN uv pip install --system --no-cache-dir -r requirements.txt && \
    # Clean
    rm requirements.txt && \
    rm -rf /var/lib/apt/lists/*

USER 1000

CMD ["python3"]
