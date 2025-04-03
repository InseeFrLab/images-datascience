ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

USER root

# Install Python packages
COPY requirements.txt .
RUN uv pip install --system --no-cache -r requirements.txt && \
    # Give user ownership
    /opt/make_user_owner.sh && \
    # Clean
    /opt/clean.sh requirements.txt

USER 1000

CMD ["python3"]
