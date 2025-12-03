#!/usr/bin/env bash

ENV_FILE=${HOME}/.bashrc

# Python configuration

if command -v pip &>/dev/null; then
    if [[ -n "$PIP_REPOSITORY" ]]; then
        echo "configuration pip (index-url)"
        pip config set global.index-url $PIP_REPOSITORY
    fi

    if [[ -n "$PATH_TO_CA_BUNDLE" ]]; then
        echo "configuration of python and pip to use a custom crt"
        pip config set global.cert $PATH_TO_CA_BUNDLE
        python /opt/certifi_ca.py
        export REQUESTS_CA_BUNDLE=$PATH_TO_CA_BUNDLE
    fi
fi

if command -v uv &>/dev/null; then
    if [[ -n "$PIP_REPOSITORY" ]]; then
        echo "export UV_DEFAULT_INDEX=$PIP_REPOSITORY" >> "$ENV_FILE"
        echo 'export UV_NATIVE_TLS=true' >> "$ENV_FILE"
    fi
fi

# R configuration
if command -v R &>/dev/null; then
  if [[ -n "$R_REPOSITORY" ]] || [[ -n "$PACKAGE_MANAGER_URL" ]]; then
      echo "configuration r (add local repository)"

      # /!\ Possible regression point for other users depending on this code.
      # The rocker image used as base injects a repository based on the CRAN environment variable, see for instance
      # https://github.com/rocker-org/rocker-versioned2/blob/677573589638617e04cad971ceafef84d5004f10/scripts/setup_R.sh#L34
      # This behavior might be unwanted when using an internal repository (eg: Nexus) instead of the public Posit
      # Package Manager instance. As such, when the PACKAGE_MANAGER_URL variable is set, we should overwrite
      # the Rprofile.site instead of appending to it. But as there might be unforeseen use cases where this
      # change could trigger problems, so I'm flagging this as such.
      if [[ -n "$PACKAGE_MANAGER_URL" ]]; then
        echo '# Rocker default configuration removed by /opt/onyxia-set-repositories.sh' > ${R_HOME}/etc/Rprofile.site

        # The unwanted behavior is setting options("repos"), but we might want to keep the user agent change from Rocker,
        # as this can potentially be used depending on how the local package manager is configured.
        echo '# https://docs.rstudio.com/rspm/admin/serving-binaries/#binaries-r-configuration-linux' >> ${R_HOME}/etc/Rprofile.site
        echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' >> ${R_HOME}/etc/Rprofile.site
      fi
      
      echo '# Proxy repository for R' >> ${R_HOME}/etc/Rprofile.site
      echo 'local({' >> ${R_HOME}/etc/Rprofile.site
      echo '  r <- getOption("repos")' >> ${R_HOME}/etc/Rprofile.site

      if [[ -n "$PACKAGE_MANAGER_URL" ]]; then

        UBUNTU_CODENAME=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d= -f2)
        # Moving from "/__linux__/" style URLs to "/bin/linux" style URLS for PACKAGE_MANAGER_URL,
        # as this allows easier management for local package managers (at least Nexus, where it allows
        # using a single repository as opposed to one per major.minor version of R)
        # See also : https://docs.posit.co/rspm/admin/serving-binaries.html#using-linux-binary-packages
        #echo "  r[\"PackageManager\"] <- \"${PACKAGE_MANAGER_URL}/${UBUNTU_CODENAME}/latest\"" >> ${R_HOME}/etc/Rprofile.site
        echo "  r[\"PackageManager\"] <- sprintf(\"${PACKAGE_MANAGER_URL}/latest/bin/linux/${UBUNTU_CODENAME}-%s/%s\", R.version[\"arch\"], substr(getRversion(), 1, 3))" >> ${R_HOME}/etc/Rprofile.site
      fi

      if [[ -n "$R_REPOSITORY" ]]; then
          echo "  r[\"LocalRepository\"] <- \"${R_REPOSITORY}\"" >> ${R_HOME}/etc/Rprofile.site
      fi

      echo '  options(repos = r)' >> ${R_HOME}/etc/Rprofile.site
      echo '})' >> ${R_HOME}/etc/Rprofile.site

      # Configure renv to use the specified package repository
      echo 'options(renv.config.repos.override = getOption("repos"))' >> ${R_HOME}/etc/Rprofile.site
  fi

fi
