ARG BASE_IMAGE=inseefrlab/onyxia-r-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ARG JAVA_VERSION="21"
ENV JAVA_VERSION=${JAVA_VERSION}
ENV JAVA_HOME="/usr/lib/jvm/java-$JAVA_VERSION-openjdk-amd64"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

USER root

COPY --chmod=0755 scripts/ /opt/

RUN /rocker_scripts/install_geospatial.sh && \
    # Install a Java JDK/JRE for R packages that use it as backend
    /opt/install-java.sh && \
    # Install useful R packages for data science
    install2.r --ncpus -1 --error \
        arrow \
        aws.s3 \
        DBI \
        duckdb \
        paws \
        quarto \
        RPostgreSQL \
        tidyverse && \
    # Install duckdb extensions
    Rscript /opt/install-duckdb-extensions.R && \
    # Fix user permissions
    /opt/fix-user-permissions.sh && \
    # Clean
    /opt/clean.sh

USER 1000

CMD ["R"]
