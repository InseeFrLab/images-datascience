ARG BASE_IMAGE=inseefrlab/onyxia-python-datascience
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

USER root

RUN /opt/install-jupyterlab.sh && \
    # Install JupyterLab extensions
    pip3 install jupyterlab-git && \
    # If using Conda and Julia is installed, make its kernel available in Jupyter
    if command -v julia && [ -n "$CONDA_DIR" ]; then \
        julia -e 'using Pkg; pkg"add IJulia"; pkg"precompile"' && \
        mv "${HOME}/.local/share/jupyter/kernels/julia"* "${CONDA_DIR}/share/jupyter/kernels/"; \
    fi && \
    # If R is installed, make its kernel available in Jupyter
    if command -v R; then \
        R -e "install.packages('IRkernel'); IRkernel::installspec()"; \
    fi && \
    # Generate jupyter server config
    jupyter server --generate-config && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${CONDA_DIR} && \
    # Clean
    jupyter lab clean && \
    rm -rf /var/lib/apt/lists/* && \
    if command -v conda; then \
        conda clean --all -f -y; \
    fi

USER 1000

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip", "0.0.0.0"]
