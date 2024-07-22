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

# VSCode extensions and configuration
RUN code-server --install-extension ms-toolsai.jupyter && \
    code-server --install-extension ms-kubernetes-tools.vscode-kubernetes-tools && \
    code-server --install-extension ms-azuretools.vscode-docker && \
    code-server --install-extension njpwerner.autodocstring && \
    code-server --install-extension oderwat.indent-rainbow && \
    code-server --install-extension mhutchie.git-graph && \
    code-server --install-extension rangav.vscode-thunder-client && \
    code-server --install-extension hediet.vscode-drawio && \
    code-server --install-extension pomdtr.excalidraw-editor && \
    code-server --install-extension streetsidesoftware.code-spell-checker && \
    code-server --install-extension streetsidesoftware.code-spell-checker-french && \
    # Language specific VSCode extensions and config
    if command -v python; then \
        code-server --install-extension ms-python.python && \
        code-server --install-extension ms-python.flake8 && \
        jq --arg pythonPath $(which python) '.["python.defaultInterpreterPath"] = $pythonPath' ${REMOTE_CONFIG_DIR}/settings.json > tmp.json && \ 
        mv tmp.json ${REMOTE_CONFIG_DIR}/settings.json; \
    fi && \
    if command -v R; then \
        code-server --install-extension reditorsupport.r && \
        code-server --install-extension RDebugger.r-debugger && \
        R -e "install.packages(c('languageserver', 'rmarkdown', 'httpgd'))" && \
        R -e "remotes::install_github('ManuelHentschel/vscDebugger')" && \
        pip install radian && \
        jq --arg rPath $(which radian) '.["r.rterm.linux"] = $rPath' ${REMOTE_CONFIG_DIR}/settings.json > tmp.json && \ 
        mv tmp.json ${REMOTE_CONFIG_DIR}/settings.json; \
    fi && \
    if command -v julia; then \
        code-server --install-extension julialang.language-julia; \
    fi && \
    if command -v quarto; then \
        code-server --install-extension quarto.quarto; \
    fi && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} && \
    # Clean
    rm -rf /var/lib/apt/lists/*

USER 1000

EXPOSE 8080

CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "${WORKSPACE_DIR}"]
