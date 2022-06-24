ARG BASE_IMAGE=ubuntu:focal
FROM $BASE_IMAGE

# Change default shell
SHELL ["/bin/bash", "-c"]

# Utilities
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        locales \
        sudo \
        tini \
        wget \
        curl \
        jq \
        bash-completion \
        vim \
        unzip && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Install helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

# Install Minio client
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc && \
    chmod +x /usr/local/bin/mc

# Install Vault
ARG VAULT_VERSION=1.11.0
RUN wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -O vault.zip  && \
    unzip vault.zip -d /usr/local/bin/ && \
    rm vault.zip

# Setup user
ARG UID=bobby
RUN useradd ${UID} --no-log-init -r --create-home
USER ${UID}

# Setup workspace
ARG WORKSPACE_DIR=/home/${UID}/work
RUN mkdir ${WORKSPACE_DIR}
WORKDIR ${WORKSPACE_DIR}

# Enable autocompletion for binaries
RUN echo 'source <(kubectl completion bash)' >>~/.bashrc && \
    echo 'source <(helm completion bash)' >>~/.bashrc && \
    vault -autocomplete-install

CMD ["/bin/bash"]
