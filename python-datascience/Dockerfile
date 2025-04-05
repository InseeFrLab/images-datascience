ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

USER root

COPY requirements.txt .

# Install Python packages and their required system libraries
RUN /opt/install-geospatial-python.sh && \
    uv pip install --system --no-cache -r requirements.txt && \
    # Fix user permissions
    /opt/fix-user-permissions.sh && \
    # Clean
    /opt/clean.sh requirements.txt

USER 1000

CMD ["python3"]
