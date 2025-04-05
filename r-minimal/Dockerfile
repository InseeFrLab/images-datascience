ARG BASE_IMAGE=inseefrlab/onyxia-base
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

# R Config
ARG R_VERSION="4.4.2"
ENV R_VERSION=${R_VERSION}
ENV R_HOME="/usr/local/lib/R"
ENV DEFAULT_USER="${USERNAME}"

USER root

# Use RStudio's package manager to download packages as binaries
ENV CRAN="https://packagemanager.posit.co/cran/__linux__/jammy/latest"

# Set up R (RSPM, OpenBLAS, littler, addtional packages)
RUN /opt/install-r.sh && \
    /rocker_scripts/setup_R.sh && \
    # Re-install system libs that may have been removed by autoremove
    /opt/install-system-libs.sh && \
    # Configure R for CUDA if parent image has CUDA
    if ! [[ -z "${CUDA_VERSION}" ]]; then /rocker_scripts/config_R_cuda.sh; fi && \
    # Install additional system libs required by some R packages
    /opt/install-system-libs-r.sh && \
    # Install some standard R packages
    install2.r --ncpus -1 --error \
        devtools \
        lintr \
        renv && \
    # Fix user permissions
    /opt/fix-user-permissions.sh && \
    # Clean
    /opt/clean.sh

USER 1000

CMD ["R"]
