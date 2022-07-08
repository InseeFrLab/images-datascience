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
    add-apt-repository "ppa:c2d4u.team/c2d4u4.0+" && \
    apt-get update && \
    # Install R and its dependencies
    apt-get install -y --no-install-recommends r-base \
                                               r-base-dev \
                                               r-recommended && \
    # Download Rocker scripts and give execution rights
    git clone --depth 1 https://github.com/rocker-org/rocker-versioned2.git /tmp/rocker-versioned2 && \
    cp -r /tmp/rocker-versioned2/scripts/ /rocker_scripts/ && \
    chmod -R 755 /rocker_scripts/ && \
    # Set up R (CRAN mirror, RSPM, OpenBLAS, littler)
    mkdir ${R_HOME}/etc/ && \
    touch ${R_HOME}/etc/Rprofile.site && \
    /rocker_scripts/setup_R.sh

RUN /rocker_scripts/install_tidyverse.sh
RUN apt-get update && apt-get install gfortran -y --no-install-recommends && /rocker_scripts/install_verse.sh
RUN /rocker_scripts/install_quarto.sh
RUN /rocker_scripts/install_geospatial.sh
RUN /rocker_scripts/install_shiny_server.sh
    # # Install additional R packages
RUN apt-get update && apt-get install libsecret-1-dev pkg-config && \
    install2.r -e -s RPostgreSQL \
                     RSQLite \
                     odbc \
                     keyring \
                     aws.s3 \
                     Rglpk \
                     paws \
                     vaultr \
                     arrow && \ 
    installGithub.r inseeFrLab/doremifasol \
                    rstudio/pagedown \
                    spyrales/gouvdown \
                    spyrales/gouvdown.fonts && \
    # Make gouvdown fonts available
    find /usr/local/lib/R/site-library/gouvdown.fonts -name "*.ttf" -exec cp '{}' /usr/local/share/fonts \; && \
    fc-cache && \
    Rscript -e "gouvdown::check_fonts_in_r()" && \
    # Clean
    apt-get purge -y software-properties-common dirmngr && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

USER ${USERNAME}

CMD ["R"]
