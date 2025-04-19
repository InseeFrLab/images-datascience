ARG BASE_IMAGE=inseefrlab/onyxia-python-datascience
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ARG USER_CONFIG_DIR="${HOME}/.local/share/code-server/User"
ARG REMOTE_CONFIG_DIR="${HOME}/.local/share/code-server/Machine"

USER root

COPY --chmod='+x' scripts/ /opt/
COPY --chown=${USERNAME}:${GROUPNAME} settings/User.json ${USER_CONFIG_DIR}/settings.json
COPY --chown=${USERNAME}:${GROUPNAME} settings/Remote.json ${REMOTE_CONFIG_DIR}/settings.json

# Install VSCode
RUN /opt/install-vscode.sh && \
    /opt/install-vscode-extensions.sh && \
    # Fix user permissions
    /opt/fix-user-permissions.sh && \
    # Clean
    /opt/clean.sh

USER 1000

EXPOSE 8080

CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "${WORKSPACE_DIR}"]
