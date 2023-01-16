ARG BASE_IMAGE=inseefrlab/onyxia-python-datascience
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER root

# Install JupyterLab and Julia kernel
RUN mamba install -y \
        jupyterlab && \
        jupyterlab-git && \
    # If Julia is installed, make the kernel available in Jupyter
    if command -v julia ; then \
        julia -e 'using Pkg; pkg"add IJulia"; pkg"precompile"' && \
        mv "${HOME}/.local/share/jupyter/kernels/julia"* "${MAMBA_DIR}/share/jupyter/kernels/"; \
    fi && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${MAMBA_DIR} && \
    # Clean 
    rm -rf "${HOME}/.local" && \
    mamba clean --all -f -y && \
    npm cache clean --force && \
    rm -rf "/home/${USERNAME}/.cache/yarn" && \
    jupyter lab clean

USER 1000

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip", "0.0.0.0"]
