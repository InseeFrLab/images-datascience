ARG BASE_IMAGE
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER ${USERNAME}

RUN mamba install -y -c conda-forge \
        ipywidgets \
        jupyterlab \
        jupyterlab-git && \
    # Make Julia kernel available in Jupyter
    julia -e 'using Pkg; pkg"add IJulia"; pkg"precompile"' && \
    mv "${HOME}/.local/share/jupyter/kernels/julia"* "${MAMBA_DIR}/share/jupyter/kernels/" && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${MAMBA_DIR} && \
    # Clean 
    rm -rf "${HOME}/.local" && \
    mamba clean --all -f -y && \
    jupyter lab clean

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip '0.0.0.0'"]
