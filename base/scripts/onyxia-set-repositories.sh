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

      # When the PACKAGE_MANAGER_URL variable is set, overwrite the Rprofile.site originating from the rocker image
      # (but still keep the UserAgent setting in case some internal repositories need it)
      if [[ -n "$PACKAGE_MANAGER_URL" ]]; then
        echo '# Rocker default configuration removed by /opt/onyxia-set-repositories.sh' > ${R_HOME}/etc/Rprofile.site

        echo '# https://docs.rstudio.com/rspm/admin/serving-binaries/#binaries-r-configuration-linux' >> ${R_HOME}/etc/Rprofile.site
        echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' >> ${R_HOME}/etc/Rprofile.site
      fi
      
      echo '# Proxy repository for R' >> ${R_HOME}/etc/Rprofile.site
      echo 'local({' >> ${R_HOME}/etc/Rprofile.site
      echo '  r <- getOption("repos")' >> ${R_HOME}/etc/Rprofile.site

      if [[ -n "$PACKAGE_MANAGER_URL" ]]; then

        UBUNTU_CODENAME=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d= -f2)
        # Using "/bin/linux" style URLS for PACKAGE_MANAGER_URL allows easier management for local package managers (eg: Nexus)
        # See also : https://docs.posit.co/rspm/admin/serving-binaries.html#using-linux-binary-packages
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
