ARG BASE_IMAGE=inseefrlab/onyxia-r-datascience
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

# Config for RStudio 
ENV DEFAULT_USER=${USERNAME}
ENV USERID=${UID}
ENV GROUPID=${GID}
ENV PATH="/usr/lib/rstudio-server/bin:${PATH}"

USER root 

# Install Rstudio using rocker's install scripts
RUN /rocker_scripts/install_rstudio.sh && \
    /rocker_scripts/install_pandoc.sh && \
    /opt/configure-rstudio.sh && \
    # Give user ownership
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} && \
    # Clean
    /opt/clean.sh /rocker_scripts/

EXPOSE 8787

CMD ["/init"]
