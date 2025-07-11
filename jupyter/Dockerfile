ARG BASE_IMAGE=inseefrlab/onyxia-python-datascience
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

USER root

COPY --chmod=0755 scripts/ /opt/

RUN /opt/install-jupyterlab.sh && \
    # Install JupyterLab extensions
    uv pip install --system --no-cache jupyterlab-git && \
    # If Julia is installed, make its kernel available in Jupyter
    if command -v julia; then \
        julia -e 'using Pkg; pkg"add IJulia"; pkg"precompile"'; \
    fi && \
    # If R is installed, make its kernel available in Jupyter
    if command -v R; then \
        R -e "install.packages('IRkernel'); IRkernel::installspec()"; \
    fi && \
    # Generate jupyter server config
    jupyter server --generate-config && \
    # Fix user permissions
    /opt/fix-user-permissions.sh && \
    # Clean
    /opt/clean.sh && \
    jupyter lab clean

USER 1000

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip", "0.0.0.0", "--notebook-dir", "${WORKSPACE_DIR}"]
