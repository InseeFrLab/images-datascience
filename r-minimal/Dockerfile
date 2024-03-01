ARG BASE_IMAGE=inseefrlab/onyxia-base
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

# R Config
ARG R_VERSION="4.3.2"
ENV R_VERSION=${R_VERSION}
ENV R_HOME="/usr/local/lib/R"
ENV DEFAULT_USER="${USERNAME}"

ARG PINNED_APT_PACKAGES="$(apt-mark showmanual)"

USER root

# Install R using rocker's install scripts
RUN git clone --branch R${R_VERSION} --depth 1 https://github.com/rocker-org/rocker-versioned2.git /tmp/rocker-versioned2 && \
    cp -r /tmp/rocker-versioned2/scripts/ /rocker_scripts/ && \
    chown -R ${USERNAME}:${GROUPNAME} /rocker_scripts/ && \
    chmod -R 700 /rocker_scripts/ && \
    echo $PINNED_APT_PACKAGES && \
    /rocker_scripts/install_R_source.sh && \
    echo $PINNED_APT_PACKAGES

# Use RStudio's package manager to download packages as binaries
ENV CRAN="https://packagemanager.posit.co/cran/__linux__/jammy/latest"

# Set up R (RSPM, OpenBLAS, littler, addtional packages)
RUN /rocker_scripts/setup_R.sh && \
    # Reinstall potentially removed system libs by autoremove in R scripts
    /opt/reinstall-pinned-packages.sh && \
    # Install additional system libs needed by R packages
    /opt/install-system-libs-R.sh && \
    # Configure R for CUDA if parent image has CUDA
    if ! [[ -z "${CUDA_VERSION}" ]]; then /rocker_scripts/config_R_cuda.sh; fi && \
    # Install useful additional packages
    install2.r --error \
        arrow \
        aws.s3 \
        devtools \
        DBI \
        duckdb \
        lintr \
        paws \
        quarto \
        renv \
        RPostgreSQL \
        styler \
        targets \
        vaultr && \
    # Install duckdb extensions
    Rscript /opt/install-duckdb-extensions.R && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${R_HOME} && \
    # Clean
    rm -rf /var/lib/apt/lists/*

USER 1000

CMD ["R"]
