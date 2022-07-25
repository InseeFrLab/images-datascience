ARG BASE_IMAGE
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER root 

ENV R_VERSION=4.2.1
ENV R_HOME=/usr/local/lib/R
ENV DEFAULT_USER=${USERNAME}
ARG DEVICE_SUFFIX

# Install R using rocker's install scripts
RUN git clone --depth 1 https://github.com/rocker-org/rocker-versioned2.git /tmp/rocker-versioned2 && \
    cp -r /tmp/rocker-versioned2/scripts/ /rocker_scripts/ && \
    chmod -R 755 /rocker_scripts/ && \
    /rocker_scripts/install_R_source.sh

# Use RStudio's package manager to download packages as binaries
ENV CRAN=https://packagemanager.rstudio.com/cran/__linux__/focal/2022-06-22

# Set up R (RSPM, OpenBLAS, littler, addtional packages)
RUN /rocker_scripts/setup_R.sh && \
    # Install system libraries
    # Reinstall some libraries removed by `apt-get autoremove` in rocker scripts
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        language-pack-fr \
        libsecret-1-dev && \
    # Configure R for CUDA if parent image has CUDA
    if ! [[ -z "${CUDA_VERSION}" ]]; then /rocker_scripts/config_R_cuda.sh; fi && \
    # Install packages bundles from rocker
    /rocker_scripts/install_tidyverse.sh && \
    /rocker_scripts/install_verse.sh && \
    /rocker_scripts/install_quarto.sh && \
    /rocker_scripts/install_geospatial.sh && \
    /rocker_scripts/install_shiny_server.sh && \
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
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${R_HOME} && \
    # Clean
    rm -rf /var/lib/apt/lists/*

# s3 support in arrow package
ENV LIBARROW_MINIMAL=false

USER ${USERNAME}

CMD ["R"]
