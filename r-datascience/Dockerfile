ARG BASE_IMAGE=inseefrlab/onyxia-r-minimal
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER root

# Install additional libraries and R packages for datascience
RUN --mount=type=secret,id=github_token \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        language-pack-fr \
        libsecret-1-dev && \
    # Install quarto
    /opt/install-quarto.sh && \
    # Install Shiny Server
    /rocker_scripts/install_shiny_server.sh && \
    # Install packages bundles from rocker
    /rocker_scripts/install_tidyverse.sh && \
    /rocker_scripts/install_verse.sh && \
    /rocker_scripts/install_geospatial.sh && \
    # Re-install system libs that may have been removed by autoremove in rocker scripts
    /opt/install-system-libs.sh && \
    # Install additional R packages
    install2.r -e -s \
        RJDemetra \
        keyring \
        odbc \
        quarto \
        Rglpk \
        RPostgreSQL \
        RSQLite && \
    # Install gouvdown
    export GITHUB_PAT=`cat /run/secrets/github_token` && \
    installGithub.r spyrales/gouvdown && \
    installGithub.r spyrales/gouvdown.fonts && \
    find /usr/local/lib/R/site-library/gouvdown.fonts -name "*.ttf" -exec cp '{}' /usr/local/share/fonts \; && \
    fc-cache && \
    R -e "gouvdown::check_fonts_in_r()" && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${R_HOME} && \
    # Clean
    rm -rf /var/lib/apt/lists/*

USER 1000

CMD ["R"]
