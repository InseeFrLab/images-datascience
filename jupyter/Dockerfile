ARG BASE_IMAGE=jupyter/python:latest
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER ${USERNAME}

RUN mamba install -y -c conda-forge \
        ipywidgets \
        jupyterlab \
        jupyterlab-git
    # Fix permissions
    #chown -R ${USERNAME}:${GROUPNAME} ${HOME} && \
    # Clean 
    #mamba clean --all -f -y && \
    #jupyter lab clean

COPY start-onyxia.sh /usr/local/bin/
EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip '0.0.0.0'"]
