ARG BASE_IMAGE=inseefrlab/onyxia-r-datascience
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

# Config for RStudio 
ENV DEFAULT_USER=${USERNAME}
ENV USERID=${UID}
ENV GROUPID=${GID}
ARG RSTUDIO_SYSTEM_CONF_FILE="/etc/rstudio/rsession.conf"
ARG RSTUDIO_USER_CONF_FILE="${HOME}/.config/rstudio/rstudio-prefs.json"
ENV PATH="/usr/lib/rstudio-server/bin:${PATH}"

USER root 

# Install Rstudio using rocker's install scripts
RUN /rocker_scripts/install_rstudio.sh && \
    /rocker_scripts/install_pandoc.sh && \
    # Set default working directory for R sessions and R projects
    echo "session-default-working-dir=${WORKSPACE_DIR}" >> ${RSTUDIO_SYSTEM_CONF_FILE} && \
    echo "session-default-new-project-dir=${WORKSPACE_DIR}" >> ${RSTUDIO_SYSTEM_CONF_FILE} && \
    # Initialize RStudio's user config file
    mkdir -p "$(dirname $RSTUDIO_USER_CONF_FILE)" && \
    echo '{}' > $RSTUDIO_USER_CONF_FILE && \
    # Give user ownership
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} && \
    # Clean
    /opt/clean.sh /rocker_scripts/

EXPOSE 8787

CMD ["/init"]
