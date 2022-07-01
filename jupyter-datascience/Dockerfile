ARG BASE_IMAGE
FROM $BASE_IMAGE

# Set shell
SHELL ["/bin/bash", "-c"]

ARG USERNAME="bobby"
USER ${USERNAME}

RUN mamba install -y -c conda-forge \
        jupyterlab \
        jupyterlab-git && \
    # Clean 
    mamba clean --all -f -y && \
    jupyter lab clean

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip '0.0.0.0'"]
