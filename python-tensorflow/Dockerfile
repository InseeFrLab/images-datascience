ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

USER root

RUN pip3 install tensorflow && \
    # Fix permissions and clean
    /opt/fix-permissions-and-clean.sh

USER 1000

CMD ["python3"]
