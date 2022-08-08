ARG BASE_IMAGE
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

# CPU/GPU
ARG DEVICE_SUFFIX

# R Config
ENV R_VERSION="4.2.1"
ENV R_HOME="/usr/local/lib/R"
ENV DEFAULT_USER=${USERNAME}
ENV CRAN="https://packagemanager.rstudio.com/cran/__linux__/focal/2022-06-22"

ENV QUARTO_VERSION="1.0.38"

# Python config for the `reticulate` package
ENV PYTHON_CONFIGURE_OPTS="--enable-shared"
ENV RETICULATE_AUTOCONFIGURE="0"

USER root 

RUN git clone --depth 1 https://github.com/rocker-org/rocker-versioned2.git /tmp/rocker-versioned2 && \
    cp -r /tmp/rocker-versioned2/scripts/ /rocker_scripts/ && \
    chmod -R +x /rocker_scripts/ && \
    # Install R using rocker's install scripts
    /rocker_scripts/install_R_source.sh && \
    # Set up R (RSPM, OpenBLAS, littler, addtional packages)
    /rocker_scripts/setup_R.sh && \
    # Install system libraries
    # (reinstall some libraries removed by `apt-get autoremove` in rocker scripts)
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        language-pack-fr \
        libsecret-1-dev && \
    # Install quarto
    /rocker_scripts/install_quarto.sh && \
    # Install shiny server
    /rocker_scripts/install_shiny_server.sh && \
    # Install Python to use the `reticulate` package
    /rocker_scripts/install_python.sh && \
    # Configure R for CUDA if parent image has CUDA
    if ! [[ -z "${CUDA_VERSION}" ]]; then /rocker_scripts/config_R_cuda.sh; fi && \
    # Install packages bundles from rocker
    /rocker_scripts/install_tidyverse.sh && \
    /rocker_scripts/install_verse.sh && \
    /rocker_scripts/install_geospatial.sh && \
    # Install additional R packages
    install2.r -e -s \
        RPostgreSQL \
        RSQLite \
        odbc \
        keyring \
        aws.s3 \
        Rglpk \
        paws \
        vaultr \
        arrow && \
    # Install gouvdown
    # Temporary set French locales to download French packages from GitHub
    export LANG=fr_FR.UTF-8 && \
    installGithub.r spyrales/gouvdown && \
    installGithub.r spyrales/gouvdown.fonts && \
    find /usr/local/lib/R/site-library/gouvdown.fonts -name "*.ttf" -exec cp '{}' /usr/local/share/fonts \; && \
    fc-cache && \
    Rscript -e "gouvdown::check_fonts_in_r()" && \
    # Set default working directory in R
    echo "setwd(\"${WORKSPACE_DIR}\")" > "${R_HOME}/etc/Renviron.site" && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${R_HOME} && \
    # Clean
    rm -rf /var/lib/apt/lists/*

# s3 support in arrow package
ENV LIBARROW_MINIMAL=false

USER ${USERNAME}

CMD ["R"]
