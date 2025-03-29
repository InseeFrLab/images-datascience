ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

USER root

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME}

USER 1000

CMD ["python3"]
