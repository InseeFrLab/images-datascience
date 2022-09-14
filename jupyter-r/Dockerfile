ARG BASE_IMAGE=inseefrlab/onyxia-r-datascience
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER root

# Install JupyterLab through pip and add R kernel
RUN if [ "`which pip3`" = "" ]; then \
        apt-get update && \
        apt-get install -y --no-install-recommends python3-pip; \
    fi && \
    # Install JupyterLab
    pip install jupyterlab && \
    # Make R kernel available in JupyterLab
    R -e "install.packages('IRkernel'); IRkernel::installspec()" && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} && \
    # Clean
    jupyter lab clean

USER ${USERNAME}

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip", "0.0.0.0"]
