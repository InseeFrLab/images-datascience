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

RUN /opt/install-julia.sh && \
    # Install common Python packages
    pip3 install -r requirements.txt && \
    # Install reticulate to use Python in R
    install2.r --error reticulate && \
    # Install quarto
    /opt/install-quarto.sh && \
    # Clean
    rm requirements.txt && \
    rm -rf /var/lib/apt/lists/*

USER 1000

CMD ["/bin/bash"]
