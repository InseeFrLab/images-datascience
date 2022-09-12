ARG BASE_IMAGE=inseefrlab/onyxia-python-datascience
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

ARG JULIA_VERSION="1.8.1"
ENV JULIA_DIR="/opt/julia"

USER root

# Install JupyterLab and minimal Julia & R kernels
RUN mamba install -y -c conda-forge \
        ipywidgets \
        jupyterlab \
        jupyterlab-git \
        r-base \
        r-irkernel && \
    # Install Julia
    julia_major_minor=$(echo "${JULIA_VERSION}" | cut -d. -f 1,2) && \
    wget -q "https://julialang-s3.julialang.org/bin/linux/x64/${julia_major_minor}/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" -O julia.tar.gz && \
    mkdir "${JULIA_DIR}" && \
    tar xzf julia.tar.gz -C "${JULIA_DIR}" --strip-components=1 && \
    # Show Julia where conda libraries are
    mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"${MAMBA_DIR}/lib\")" >> /etc/julia/juliarc.jl && \
    # Install additional Julia packages
    julia -e 'import Pkg; Pkg.update()' && \
    julia -e 'import Pkg; Pkg.add("HDF5")' && \
    # Make Julia kernel available in Jupyter
    julia -e 'using Pkg; pkg"add IJulia"; pkg"precompile"' && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${MAMBA_DIR} ${JULIA_DIR} && \
    # Clean 
    rm -rf "${HOME}/.local" julia.tar.gz && \
    mamba clean --all -f -y && \
    jupyter lab clean

USER ${USERNAME}

EXPOSE 8888

CMD ["jupyter", "lab", "--no-browser", "--ip", "0.0.0.0"]
