ARG BASE_IMAGE
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER root 

ENV R_VERSION=4.2.1
ENV R_HOME=/usr/local/lib/R

RUN apt-get update && \
    # Install system libraries
    apt-get install -y --no-install-recommends software-properties-common dirmngr && \
    # Add relevant repositories
    wget -qO - https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" && \
    add-apt-repository ppa:c2d4u.team/c2d4u4.0+ && \
    # Install R and its dependencies
    apt-get install -y --no-install-recommends r-base \
                                               r-base-core \
                                               r-base-dev \
                                               r-recommended \
                                               r-cran-devtools \
                                               r-cran-roxygen2 \
                                               r-cran-tidyverse \
                                               r-cran-ggplot2 && \
    # Clean
    apt-get purge -y software-properties-common dirmngr && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

CMD ["R"]
