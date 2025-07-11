ARG BASE_IMAGE=ubuntu:24.04
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

# System configuration
SHELL ["/bin/bash", "-c"]
ENV SHELL="/bin/bash"
ENV DEBIAN_FRONTEND="noninteractive"

# User configuration
ENV USERNAME="onyxia"
ENV UID="1000"
ENV GROUPNAME="users"
ENV GID="100"
ENV HOME="/home/${USERNAME}"
ENV WORKSPACE_DIR="${HOME}/work"
RUN groupmod -g ${GID} ${GROUPNAME} && \
    # Remove defaut Ubuntu user (since 24.04)
    userdel -r ubuntu && \
    # Setup custom user with sudo rights
    useradd ${USERNAME} --uid=${UID} -g ${GROUPNAME} --groups sudo -r --no-log-init --create-home && \
    # Create workspace
    mkdir -p ${WORKSPACE_DIR} && \
    # Disable default sudo message when opening shell
    touch ${HOME}/.sudo_as_admin_successful
WORKDIR ${WORKSPACE_DIR}

COPY --chmod=0755 scripts/ /opt/

RUN /opt/install-system-libs.sh && \
    # Make sudo passwordless
    echo 'onyxia ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    # Disable default sudo message when opening shell
    touch ${HOME}/.sudo_as_admin_successful && \
    # Generate locales
    locale-gen en_US.UTF-8 && \
    # Install common clients useful for Onyxia
    /opt/install-kubectl.sh && \
    /opt/install-helm.sh && \
    /opt/install-mc.sh && \
    /opt/install-duckdb-cli.sh && \
    /opt/install-duckdb-extensions.sh && \
    /opt/install-quarto.sh && \
    # Fix user permissions
    /opt/fix-user-permissions.sh && \
    # Clean
    /opt/clean.sh

# Set locales
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

USER 1000
