# syntax=docker/dockerfile:1
FROM BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER root

# Install JupyterLab
RUN /opt/install-jupyterlab.sh && \
    # If using Conda and Julia is installed, make its kernel available in Jupyter
    if command -v julia && [ -n "$MAMBA_DIR" ]; then \
        julia -e 'using Pkg; pkg"add IJulia"; pkg"precompile"' && \
        mv "${HOME}/.local/share/jupyter/kernels/julia"* "${MAMBA_DIR}/share/jupyter/kernels/"; \
    fi && \
    # If R is installed, make its kernel available in Jupyter
    if command -v R; then \
        R -e "install.packages('IRkernel'); IRkernel::installspec()"; \
    fi && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${MAMBA_DIR} && \
    # Clean
    jupyter lab clean && \
    rm -rf /var/lib/apt/lists/* && \
    if command -v mamba; then \
        mamba clean --all -f -y; \
    fi

USER 1000

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip", "0.0.0.0"]
