ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

ARG JULIA_VERSION="1.7.3"
ENV JULIA_DIR="/opt/julia"
ENV PATH="${JULIA_DIR}/bin:${PATH}"

USER root

COPY conda-env.yml .

RUN mamba env update -n base -f conda-env.yml && \
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
    # Install Quarto latest version
    QUARTO_DL_URL=$(wget -qO- https://quarto.org/docs/download/_download.json | grep -oP '(?<=\"download_url\":\s\")https.*linux-amd64.deb') && \
    wget -q ${QUARTO_DL_URL} -O quarto.deb && \
    dpkg -i quarto.deb && \
    quarto check install && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${MAMBA_DIR} ${JULIA_DIR} && \
    # Clean
    rm conda-env.yml julia.tar.gz quarto.deb && \ 
    mamba clean --all -f -y

USER ${USERNAME}

CMD ["python3"]
