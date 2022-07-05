ARG BASE_IMAGE
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER root

# Install code-server
ARG CODE_SERVER_VERSION="4.5.0"
RUN curl -fOL https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_amd64.deb && \
    dpkg -i code-server_${VERSION}_amd64.deb

USER ${USERNAME}

EXPOSE 8080
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "${WORKSPACE_DIR}"]
