ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

USER root

# Install Python packages
COPY requirements.txt .
RUN uv pip install --system --no-cache -r requirements.txt && \
    # Give user ownership on Python's directory for user-installed packages 
    chown -R ${USERNAME}:${GROUPNAME} /usr/local/lib/python${PYTHON_VERSION%.*}/site-packages/ && \
    # Clean
    rm requirements.txt && \
    rm -rf /var/lib/apt/lists/*

USER 1000

CMD ["python3"]
