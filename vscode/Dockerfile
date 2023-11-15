ARG BASE_IMAGE=inseefrlab/onyxia-python-datascience
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ARG USER_CONFIG_DIR="${HOME}/.local/share/code-server/User"
ARG REMOTE_CONFIG_DIR="${HOME}/.local/share/code-server/Machine"

USER root

RUN curl -fsSL https://code-server.dev/install.sh | bash && \
    # Install VSCode extensions
    code-server --install-extension ms-toolsai.jupyter && \
    code-server --install-extension ms-kubernetes-tools.vscode-kubernetes-tools && \
    code-server --install-extension ms-azuretools.vscode-docker && \
    code-server --install-extension njpwerner.autodocstring && \
    code-server --install-extension redhat.vscode-yaml && \
    code-server --install-extension mhutchie.git-graph && \
    code-server --install-extension GordonSmith.observable-js && \
    code-server --install-extension rangav.vscode-thunder-client && \
    # Install language specific VSCode extensions
    if command -v python; then \
        code-server --install-extension ms-python.python && \
        code-server --install-extension ms-python.flake8; \
    fi && \
    if command -v R; then \
        code-server --install-extension reditorsupport.r && \
        R -e "install.packages('languageserver')"; \
    fi && \
    if command -v julia; then \
        code-server --install-extension julialang.language-julia; \
    fi && \
    if command -v quarto; then \
        code-server --install-extension quarto.quarto; \
    fi && \
    # Create directories to store custom VSCode settings
    mkdir -p ${USER_CONFIG_DIR} ${REMOTE_CONFIG_DIR} && \
    # Set Conda binary path in remote settings to auto activate base env when running Python code
    echo "{\"python.defaultInterpreterPath\": \"${MAMBA_DIR}/bin/python\"}" > ${REMOTE_CONFIG_DIR}/settings.json && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} && \
    # Clean
    rm -rf /var/lib/apt/lists/*

# Copy custom VSCode User settings
COPY --chown=${USERNAME}:${GROUPNAME} settings/User.json ${USER_CONFIG_DIR}/settings.json

USER 1000

EXPOSE 8080

CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "${WORKSPACE_DIR}"]
