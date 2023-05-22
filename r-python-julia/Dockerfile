ARG BASE_IMAGE=inseefrlab/onyxia-r-minimal
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

ENV JULIA_DIR="/opt/julia"
ENV PATH="${JULIA_DIR}/bin:${PATH}"

# Python config for the `reticulate` package
ENV PYTHON_CONFIGURE_OPTS="--enable-shared"
ENV RETICULATE_AUTOCONFIGURE="0"

USER root

COPY requirements.txt .

RUN wget -O - https://raw.githubusercontent.com/rocker-org/rocker-versioned2/R4.2.2/scripts/install_python.sh | bash && \
    # Install base Python packages
    pip install -r requirements.txt && \
    # Install Julia
    /opt/install-julia.sh && \
    # Install quarto
    /opt/install-quarto.sh && \
    # Clean
    rm requirements.txt && \
    rm -rf /var/lib/apt/lists/*

USER 1000

CMD ["/bin/bash"]
