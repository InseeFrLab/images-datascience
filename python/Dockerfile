ARG BASE_IMAGE
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

# CPU/GPU
ARG DEVICE_SUFFIX

ARG PYTHON_VERSION="3.9"
ARG JULIA_VERSION="1.7.3"
ARG QUARTO_VERSION="1.0.38"
ARG MAMBAFORGE_VERSION="4.12.0-2"

ENV MAMBA_DIR="/opt/mamba"
ENV JULIA_DIR="/opt/julia"

ENV PATH="${MAMBA_DIR}/bin:${JULIA_DIR}/bin:${PATH}"

USER root

COPY environment/lib-datascience.yml .
COPY environment/lib-dl${DEVICE_SUFFIX}.yml .

RUN wget -q https://github.com/conda-forge/miniforge/releases/download/${MAMBAFORGE_VERSION}/Mambaforge-${MAMBAFORGE_VERSION}-Linux-x86_64.sh -O mambaforge.sh && \
    # Install mambaforge
    /bin/bash mambaforge.sh -b -p "${MAMBA_DIR}" && \
    # Set specified Python version
    mamba install python=="${PYTHON_VERSION}" && \
    # Merge Conda env files to install DL libraries for CPU or GPU
    cat lib-datascience.yml lib-dl${DEVICE_SUFFIX}.yml > env-specs.yml && \
    # Install packages
    mamba env update -n base -f env-specs.yml && \
    # Activate custom Conda env by default in shell
    echo ". ${MAMBA_DIR}/etc/profile.d/conda.sh && conda activate" >> ${HOME}/.bashrc && \
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
    # Install Quarto
    wget -q "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" -O quarto.deb && \
    dpkg -i quarto.deb && \
    quarto check install && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${MAMBA_DIR} ${JULIA_DIR} && \
    # Clean
    rm mambaforge.sh lib-datascience.yml lib-dl${DEVICE_SUFFIX}.yml env-specs.yml julia.tar.gz quarto.deb && \ 
    mamba clean --all -f -y

USER ${USERNAME}

CMD ["python3"]
