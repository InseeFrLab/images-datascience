ARG BASE_IMAGE=inseefrlab/base-datascience
FROM $BASE_IMAGE

USER root

# Install system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        bash-completion \
        ca-certificates \
        curl \
        jq \
        locales \
        sudo \
        tini \
        unzip \
        wget && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${USER}
