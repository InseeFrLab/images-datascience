ARG BASE_IMAGE=inseefrlab/onyxia-r-minimal
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

# Python config for the `reticulate` package
ENV PYTHON_CONFIGURE_OPTS="--enable-shared"
ENV RETICULATE_AUTOCONFIGURE="0"

USER root

# Install additional libraries and R packages for datascience
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        language-pack-fr \
        libsecret-1-dev && \
    # Install Shiny Server
    /rocker_scripts/install_shiny_server.sh && \
    # Install Quarto latest version
    /rocker_scripts/install_quarto.sh && \
    # Install Python to use the `reticulate` package
    # /rocker_scripts/install_python.sh && \
    # Install packages bundles from rocker
    /rocker_scripts/install_tidyverse.sh && \
    /rocker_scripts/install_verse.sh && \
    /rocker_scripts/install_geospatial.sh && \
    # Re-install system libs that may have been removed by autoremove in rocker scripts
    /opt/install-system-libs.sh && \
    # Install additional R packages
    install2.r -e -s \
        arrow \
        aws.s3 \
        keyring \
        odbc \
        paws \
        quarto \
        Rglpk \
        RPostgreSQL \
        RSQLite \
        vaultr && \
    # Install gouvdown
    # Temporary set French locales to download French packages from GitHub
    export LANG=fr_FR.UTF-8 && \
    installGithub.r spyrales/gouvdown && \
    installGithub.r spyrales/gouvdown.fonts && \
    find /usr/local/lib/R/site-library/gouvdown.fonts -name "*.ttf" -exec cp '{}' /usr/local/share/fonts \; && \
    fc-cache && \
    R -e "gouvdown::check_fonts_in_r()" && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${R_HOME} && \
    # Clean
    rm -rf /var/lib/apt/lists/*

USER ${USERNAME}

CMD ["R"]
