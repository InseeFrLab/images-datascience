ARG BASE_IMAGE=inseefrlab/onyxia-r-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ARG JAVA_VERSION="17"
ENV JAVA_VERSION=${JAVA_VERSION}
ENV JAVA_HOME="/usr/lib/jvm/java-$JAVA_VERSION-openjdk-amd64"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

USER root

# Install additional libraries and R packages for datascience
RUN /opt/install-java.sh && \
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
    /opt/clean.sh

USER 1000

CMD ["R"]
