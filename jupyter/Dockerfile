ARG BASE_IMAGE=inseefrlab/onyxia-python-datascience
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

USER root

RUN /opt/install-jupyterlab.sh && \
    # Install JupyterLab extensions
    uv pip install --system jupyterlab-git && \
    # If Python is installed, make its kernel available in Jupyter
    if command -v python3; then \
        uv pip install --system ipykernel nbclient nbformat; \
    fi && \
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
