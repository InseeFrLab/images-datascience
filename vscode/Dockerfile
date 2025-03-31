ARG BASE_IMAGE=inseefrlab/onyxia-python-datascience
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ARG USER_CONFIG_DIR="${HOME}/.local/share/code-server/User"
ARG REMOTE_CONFIG_DIR="${HOME}/.local/share/code-server/Machine"

USER root

# Install VSCode
RUN curl -fsSL https://code-server.dev/install.sh | bash && \
    mkdir -p ${USER_CONFIG_DIR} ${REMOTE_CONFIG_DIR}

# Copy custom VSCode settings
COPY --chown=${USERNAME}:${GROUPNAME} settings/User.json ${USER_CONFIG_DIR}/settings.json
COPY --chown=${USERNAME}:${GROUPNAME} settings/Remote.json ${REMOTE_CONFIG_DIR}/settings.json

# VSCode extensions and language-specific configuration
RUN /opt/install-vscode-extensions.sh && \
    # Fix permissions and clean
    /opt/fix-permissions-and-clean.sh

USER 1000

EXPOSE 8080

CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "${WORKSPACE_DIR}"]
