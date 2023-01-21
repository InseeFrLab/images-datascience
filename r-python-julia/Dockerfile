ARG BASE_IMAGE=inseefrlab/onyxia-r-minimal
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

ENV JULIA_VERSION="1.8.5"
ENV JULIA_DIR="/opt/julia"
ENV PATH="${JULIA_DIR}/bin:${PATH}"

# Python config for the `reticulate` package
ENV PYTHON_CONFIGURE_OPTS="--enable-shared"
ENV RETICULATE_AUTOCONFIGURE="0"

COPY requirements.txt .

RUN /rocker_scripts/install_python.sh && \
    # Install base Python packages
    pip install -r requirements.txt && \
    # Install Julia
    /opt/install-julia.sh && \
    # Clean
    rm requirements.txt

USER 1000

CMD ["/bin/bash"]
