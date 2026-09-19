ARG BASE_IMAGE=inseefrlab/onyxia-r-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ARG PYTHON_VERSION="3.13.15"
ENV PYTHON_VERSION=${PYTHON_VERSION}

# Python is installed by uv (see /opt/install-python.sh) in /opt/python, in the folder uv names after the version
ARG PYTHON_DIR="/opt/python/cpython-${PYTHON_VERSION}-linux-x86_64-gnu"
ENV PATH="${PYTHON_DIR}/bin:${PATH}"

USER root

COPY --chmod=0755 scripts/ /opt/
COPY requirements.txt .

RUN /opt/install-python.sh && \
    /opt/install-julia.sh && \
    # Install common Python packages
    uv pip install --system --no-cache -r requirements.txt && \
    # Fix user permissions
    /opt/fix-user-permissions.sh && \
    # Clean
    /opt/clean.sh requirements.txt

USER 1000

CMD ["/bin/bash"]
