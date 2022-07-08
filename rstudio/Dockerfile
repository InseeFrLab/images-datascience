ARG BASE_IMAGE
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER root 

ENV S6_VERSION=v2.1.0.2
ENV RSTUDIO_VERSION=2022.07.0+548
ENV DEFAULT_USER=${USERNAME}
ENV PANDOC_VERSION=default
ENV PATH=/usr/lib/rstudio-server/bin:$PATH

# Install Rstudio using rocker's install scripts
RUN git clone --depth 1 https://github.com/rocker-org/rocker-versioned2.git /tmp/rocker-versioned2 && \
    cp -r /tmp/rocker-versioned2/scripts/ /rocker_scripts/ && \
    chmod -R 755 /rocker_scripts/ && \
    /rocker_scripts/install_rstudio.sh && \
    /rocker_scripts/install_pandoc.sh

USER ${USERNAME}

EXPOSE 8787

CMD ["/init"]
