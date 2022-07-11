ARG BASE_IMAGE
FROM $BASE_IMAGE

# Set default shell
SHELL ["/bin/bash", "-c"]
ENV SHELL="/bin/bash"

# Setup user & workspace
ENV USERNAME="onyxia"
ENV UID="1000"
ENV GROUPNAME="users"
ENV HOME="/home/${USERNAME}"
ENV WORKSPACE_DIR=${HOME}/work
RUN useradd ${USERNAME} --uid=${UID} -g ${GROUPNAME} --groups sudo -r --no-log-init --create-home && \
    passwd -d ${USERNAME} && \
    mkdir ${WORKSPACE_DIR}
WORKDIR ${WORKSPACE_DIR}

USER root

# Install system libraries
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        bash-completion \
        build-essential \
        ca-certificates \
        curl \
        git \
        jq \
        less \
        locales \
        openssh-client \
        sudo \
        tini \
        unzip \
        wget && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install common binaries : kubectl, helm, mc, vault
ARG VAULT_VERSION="1.11.0"
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    # kubectl
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && \
    echo 'source <(kubectl completion bash)' >> /home/${USERNAME}/.bashrc && \
    # helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm ./get_helm.sh && \
    echo 'source <(helm completion bash)' >> /home/${USERNAME}/.bashrc && \
    # mc
    wget https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc && \
    chmod +x /usr/local/bin/mc && \
    # vault
    wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip -O vault.zip  && \
    unzip vault.zip -d /usr/local/bin/ && \
    rm vault.zip && \
    vault -autocomplete-install && \
    # fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME}

USER ${USERNAME}

CMD ["/bin/bash"]
