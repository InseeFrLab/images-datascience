ARG BASE_IMAGE=inseefrlab/onyxia-r-minimal
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

ENV JULIA_VERSION="1.8.5"

# Python config for the `reticulate` package
ENV PYTHON_CONFIGURE_OPTS="--enable-shared"
ENV RETICULATE_AUTOCONFIGURE="0"

COPY install-julia.sh /opt/install-julia.sh

RUN /rocker_scripts/install_python.sh && \
    /opt/install-julia.sh

USER 1000

CMD ["/bin/bash"]
