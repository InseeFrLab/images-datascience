ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

USER root

# Install Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && \
    # Fix permissions and clean
    /opt/fix-permissions-and-clean.sh && \
    rm requirements.txt

USER 1000

CMD ["python3"]
