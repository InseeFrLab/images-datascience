ARG BASE_IMAGE=inseefrlab/onyxia-r-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ENV JULIA_DIR="/opt/julia"
ENV PATH="${HOME}/.local/bin:${JULIA_DIR}/bin:${PATH}"

# Python config for the `reticulate` package
ENV PYTHON_CONFIGURE_OPTS="--enable-shared"
ENV RETICULATE_AUTOCONFIGURE="0"

USER root

COPY requirements.txt .

RUN /opt/install-python.sh && \
    /opt/install-julia.sh && \
    # Install common Python packages
    pip3 install -r requirements.txt && \
    # Install and configure reticulate to use Python in R
    install2.r --error reticulate && \
    R -q -e 'reticulate::py_discover_config(required_module = NULL, use_environment = NULL)' && \
    # Fix permissions and clean
    /opt/fix-permissions-and-clean.sh && \
    rm requirements.txt

USER 1000

CMD ["/bin/bash"]
