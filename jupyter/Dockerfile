ARG BASE_IMAGE=inseefrlab/onyxia-python-datascience
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER ${USERNAME}

RUN mamba install -y -c conda-forge \
        ipywidgets \
        jupyterlab \
        jupyterlab-git && \
    # If Julia is installed, make it available as a kernel in Jupyter
    if [ $(which julia) ]; then \
        julia -e 'using Pkg; pkg"add IJulia"; pkg"precompile"' && \
        mv "${HOME}/.local/share/jupyter/kernels/julia"* "${MAMBA_DIR}/share/jupyter/kernels/"; \
    fi && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${MAMBA_DIR} && \
    # Clean 
    rm -rf "${HOME}/.local" && \
    mamba clean --all -f -y && \
    jupyter lab clean

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip '0.0.0.0'"]
