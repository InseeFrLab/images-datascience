ARG BASE_IMAGE=inseefrlab/onyxia-python-datascience
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER ${USERNAME}

# Install JupyterLab and minimal Julia & R kernels
RUN mamba install -y -c conda-forge \
        ipywidgets \
        jupyterlab \
        julia && \
        r-base && \
        r-irkernel && \
    # Make Julia kernel available in Jupyter
    julia -e 'using Pkg; pkg"add IJulia"; pkg"precompile"' && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${MAMBA_DIR} && \
    # Clean 
    rm -rf "${HOME}/.local" && \
    mamba clean --all -f -y && \
    jupyter lab clean

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip '0.0.0.0'"]
