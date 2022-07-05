ARG BASE_IMAGE
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER ${USERNAME}

RUN mamba install -y -c conda-forge \
        jupyterlab \
        ipywidgets \
        jupyterlab-git && \
    # Clean 
    mamba clean --all -f -y && \
    jupyter lab clean && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME}

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip '0.0.0.0'"]
