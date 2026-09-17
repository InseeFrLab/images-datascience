ARG BASE_IMAGE=inseefrlab/onyxia-r-datascience
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

# Config for RStudio
ENV DEFAULT_USER=${USERNAME}
ENV USERID=${UID}
ENV GROUPID=${GID}
ENV PATH="/usr/lib/rstudio-server/bin:${PATH}"

USER root

COPY --chmod=0755 scripts/ /opt/

# Install Rstudio using rocker's install scripts
RUN /rocker_scripts/install_rstudio.sh && \
    /rocker_scripts/install_pandoc.sh && \
    /opt/configure-rstudio.sh && \
    # Install opencode
    /opt/install-opencode.sh && \
    # Fix user permissions
    /opt/fix-user-permissions.sh && \
    # Clean
    /opt/clean.sh /rocker_scripts/

EXPOSE 8787

# Config for rootless
ENV USER=${USERNAME}
RUN chown -R ${USER} /var/lib/rstudio-server && \
    chown -R ${USER} /usr/lib/rstudio-server && \
    chown -R ${USER} /etc/rstudio

USER 1000

# CMD for regular, root launch
# CMD ["/init"]
# CMD for rootless launch
CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize=0", "--auth-none=0", "--auth-stay-signed-in-days=30", "--auth-timeout-minutes=720", "--server-user=onyxia", "--auth-pam-helper-path=pam-helper"]
