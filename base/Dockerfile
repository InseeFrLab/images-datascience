ARG BASE_IMAGE=ubuntu:24.04
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

# System configuration
SHELL ["/bin/bash", "-c"]
ENV SHELL="/bin/bash"
ENV DEBIAN_FRONTEND="noninteractive"

# User configuration
ENV USERNAME="onyxia"
# ENV UID="1000" # Cannot rely on that, some clusters assign random uids.
ENV GROUPNAME="users"
# ENV GID="100" # Cannot rely on that, some clusters assign random uids.
ENV HOME="/home/${USERNAME}"
ENV WORKSPACE_DIR="${HOME}/work"
RUN userdel -r ubuntu && \
    # (Above) Remove defaut Ubuntu user (since 24.04)
    # groupadd -g 0 root || true && \ # this group already exists
    # Setup custom user with sudo rights
    useradd -l -r -g 0 -d ${HOME} -s /bin/bash ${USERNAME} && \
    # Create workspace
    mkdir -p ${WORKSPACE_DIR} && \
    # Disable default sudo message when opening shell
    touch ${HOME}/.sudo_as_admin_successful

    WORKDIR ${WORKSPACE_DIR}

COPY --chmod=0755 scripts/ /opt/

# If true, all common clients useful for Onyxia will be installed
ARG INSTALL_CLIENT_ALL=true

# Individual switches (default to 'default' to inherit master behavior)
ARG INSTALL_CLIENT_KUBECTL=default
ARG INSTALL_CLIENT_HELM=default
ARG INSTALL_CLIENT_AWSCLI=default
ARG INSTALL_CLIENT_MC=default
ARG INSTALL_CLIENT_DUCKDB=default
ARG INSTALL_CLIENT_QUARTO=default

RUN /opt/install-system-libs.sh && \
    # Make sudo passwordless
    echo 'onyxia ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    # Disable default sudo message when opening shell
    touch ${HOME}/.sudo_as_admin_successful && \
    # Generate locales
    locale-gen en_US.UTF-8 && \
    # Conditionally INSTALL_CLIENT common clients useful for Onyxia
    if [ "$INSTALL_CLIENT_KUBECTL" = "true" ] || { [ "$INSTALL_CLIENT_ALL" = "true" ] && [ "$INSTALL_CLIENT_KUBECTL" != "false" ]; }; then /opt/install-kubectl.sh; fi && \
    if [ "$INSTALL_CLIENT_HELM" = "true" ] || { [ "$INSTALL_CLIENT_ALL" = "true" ] && [ "$INSTALL_CLIENT_HELM" != "false" ]; }; then /opt/install-helm.sh; fi && \
    if [ "$INSTALL_CLIENT_AWSCLI" = "true" ] || { [ "$INSTALL_CLIENT_ALL" = "true" ] && [ "$INSTALL_CLIENT_AWSCLI" != "false" ]; }; then /opt/install-awscli.sh; fi && \
    if [ "$INSTALL_CLIENT_MC" = "true" ] || { [ "$INSTALL_CLIENT_ALL" = "true" ] && [ "$INSTALL_CLIENT_MC" != "false" ]; }; then /opt/install-mc.sh; fi && \
    if [ "$INSTALL_CLIENT_DUCKDB" = "true" ] || { [ "$INSTALL_CLIENT_ALL" = "true" ] && [ "$INSTALL_CLIENT_DUCKDB" != "false" ]; }; then /opt/install-duckdb-cli.sh && /opt/install-duckdb-extensions.sh; fi && \
    if [ "$INSTALL_CLIENT_QUARTO" = "true" ] || { [ "$INSTALL_CLIENT_ALL" = "true" ] && [ "$INSTALL_CLIENT_QUARTO" != "false" ]; }; then /opt/install-quarto.sh; fi && \
    \
    # Fix user permissions
    /opt/fix-user-permissions.sh && \
    # Clean
    /opt/clean.sh

# Set locales
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

USER 1000