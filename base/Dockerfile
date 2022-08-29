ARG BASE_IMAGE=ubuntu:22.04
FROM $BASE_IMAGE

# Set default shell
SHELL ["/bin/bash", "-c"]
ENV SHELL="/bin/bash"
ENV DEBIAN_FRONTEND="noninteractive"

# Setup user & workspace
ENV USERNAME="onyxia"
ENV UID="1000"
ENV GROUPNAME="users"
ENV GID="100"
ENV HOME="/home/${USERNAME}"
ENV WORKSPACE_DIR="${HOME}/work"
RUN groupmod -g ${GID} ${GROUPNAME} && \
    # Setup custom user with sudo rights
    useradd ${USERNAME} --uid=${UID} -g ${GROUPNAME} --groups sudo -r --no-log-init --create-home && \
    passwd -d ${USERNAME} && \
    # Create workspace
    mkdir ${WORKSPACE_DIR} && \
    # Disable default sudo message when opening shell
    touch ${HOME}/.sudo_as_admin_successful
WORKDIR ${WORKSPACE_DIR}

USER root

RUN apt-get update && \
    apt-get upgrade -y && \
    ## Install system libraries
    apt-get install -y --no-install-recommends \
        bash-completion \
        build-essential \
        ca-certificates \
        curl \
        git \
        jq \
        less \
        locales \
        nano-tiny \
        openssh-client \
        sudo \
        tini \
        unzip \
        vim-tiny \
        wget && \
    # Set up locales
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && \
    ## Install common binaries required for Onyxia
    # kubectl
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl && \
    echo 'source <(kubectl completion bash)' >> /home/${USERNAME}/.bashrc && \
    # helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod +x get_helm.sh && \
    ./get_helm.sh && \
    echo 'source <(helm completion bash)' >> /home/${USERNAME}/.bashrc && \
    # mc
    wget -q https://dl.min.io/client/mc/release/linux-amd64/mc -O /usr/local/bin/mc && \
    chmod +x /usr/local/bin/mc && \
    # vault
    VAULT_LATEST_VERSION=$(curl --silent "https://api.github.com/repos/hashicorp/vault/releases/latest" | grep -Po '"tag_name": "v\K.*?(?=")') && \
    wget -q https://releases.hashicorp.com/vault/${VAULT_LATEST_VERSION}/vault_${VAULT_LATEST_VERSION}_linux_amd64.zip -O vault.zip  && \
    unzip vault.zip -d /usr/local/bin/ && \
    vault -autocomplete-install && \
    # Fetch Onyxia init script
    mkdir /scripts && \
    wget https://inseefrlab.github.io/onyxia/onyxia-init.sh -O /scripts/onyxia-init.sh && \
    chmod +x /scripts/onyxia-init.sh && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} && \
    # Clean
    rm get_helm.sh vault.zip && \
    rm -rf /var/lib/apt/lists/*

USER ${USERNAME}

CMD ["/bin/bash"]
