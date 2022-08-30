ARG BASE_IMAGE=inseefrlab/onyxia-base
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

# R Config
ENV R_VERSION="4.2.1"
ENV R_HOME="/usr/local/lib/R"
ENV DEFAULT_USER=${USERNAME}

USER root

# Install R using rocker's install scripts
RUN git clone --depth 1 https://github.com/rocker-org/rocker-versioned2.git /tmp/rocker-versioned2 && \
    cp -r /tmp/rocker-versioned2/scripts/ /rocker_scripts/ && \
    chmod -R 755 /rocker_scripts/ && \
    /rocker_scripts/install_R_source.sh

# Use RStudio's package manager to download packages as binaries
ENV CRAN=https://packagemanager.rstudio.com/cran/__linux__/focal/latest

# Set up R (RSPM, OpenBLAS, littler, addtional packages)
RUN /rocker_scripts/setup_R.sh && \
    # Reinstall libraries removed by `apt-get autoremove` in rocker scripts)
    /opt/install-system-libs.sh && \
    # Configure R for CUDA if parent image has CUDA
    if ! [[ -z "${CUDA_VERSION}" ]]; then /rocker_scripts/config_R_cuda.sh; fi && \
    # Set default working directory in R
    echo "setwd(\"${WORKSPACE_DIR}\")" > "${R_HOME}/etc/Rprofile.site" && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${R_HOME} && \
    # Clean
    rm -rf /var/lib/apt/lists/*

USER ${USERNAME}

CMD ["R"]
