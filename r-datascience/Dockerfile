ARG BASE_IMAGE=inseefrlab/onyxia-r-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ARG JAVA_VERSION="17"
ENV JAVA_VERSION=${JAVA_VERSION}

USER root

# temporary to POC instal-java.sh
COPY scripts/ /opt/
RUN chmod -R +x /opt/

# Install additional libraries and R packages for datascience
RUN /opt/install-quarto.sh && \
    # Install JDK
    /opt/install-java.sh && \
    # Install Shiny Server
    /rocker_scripts/install_shiny_server.sh && \
    # Install packages bundles from rocker
    /rocker_scripts/install_tidyverse.sh && \
    /rocker_scripts/install_geospatial.sh && \
    # Re-install system libs that may have been removed by autoremove in rocker scripts
    /opt/install-system-libs.sh && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${R_HOME} && \
    # Clean
    rm -rf /var/lib/apt/lists/*

USER 1000

CMD ["R"]
