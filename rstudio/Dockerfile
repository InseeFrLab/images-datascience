ARG BASE_IMAGE
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

ENV DEFAULT_USER=${USERNAME}
ENV USERID=${UID}
ENV GROUPID=${GID}

ENV PATH="/usr/lib/rstudio-server/bin:$PATH"

USER root 

# Install Rstudio using rocker's install scripts
RUN git clone --depth 1 https://github.com/rocker-org/rocker-versioned2.git /tmp/rocker-versioned2 && \
    cp -r /tmp/rocker-versioned2/scripts/ /rocker_scripts/ && \
    chmod -R 755 /rocker_scripts/ && \
    /rocker_scripts/install_rstudio.sh && \
    /rocker_scripts/install_pandoc.sh && \
    # Ensure consistency between installed quarto CLI and RStudio's bundled version
    /rocker_scripts/install_quarto.sh && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME}

EXPOSE 8787

CMD ["/init"]
