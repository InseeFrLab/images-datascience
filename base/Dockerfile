ARG BASE_IMAGE=ubuntu:22.04
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

# System-wide configuration
SHELL ["/bin/bash", "-c"]
ENV SHELL="/bin/bash"
ENV DEBIAN_FRONTEND="noninteractive"

# Setup user & workspace
ENV USERNAME="onyxia"
ENV UID="1000"
ENV GROUPNAME="users"
ENV GID="100"
ENV HOME="/home/${USERNAME}"
ENV WORKSPACE_DIR="${HOME}/work"
WORKDIR ${WORKSPACE_DIR}

COPY --chmod=x scripts/ /opt/

RUN groupmod -g ${GID} ${GROUPNAME} && \
    # Setup custom user with sudo rights
    useradd ${USERNAME} --uid=${UID} -g ${GROUPNAME} --groups sudo -r --no-log-init --create-home && \
    # Make sudo passwordless
    echo 'onyxia ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    # Disable default sudo message when opening shell
    touch ${HOME}/.sudo_as_admin_successful && \
    # Install core system libraries
    /opt/install-system-libs.sh && \
    # Generate locales
    locale-gen en_US.UTF-8 && \
    # Install common clients useful for Onyxia
    /opt/install-kubectl.sh && \
    /opt/install-helm.sh && \
    /opt/install-mc.sh && \
    /opt/install-duckdb-cli.sh && \
    /opt/install-duckdb-extensions.sh && \
    /opt/install-quarto.sh && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} && \
    # Clean
    /opt/clean.sh

# Set locales
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

USER 1000
