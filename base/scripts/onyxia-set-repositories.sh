#!/usr/bin/env bash

if [ "$DEBUG_LOG" = "1" ]; then
    OUT="/dev/stdout"
    ERR="/dev/stderr"
else
    OUT="/dev/null"
    ERR="/dev/null"
fi

if [[ $SUDO -eq 0 ]]; then
    ENV_FILE=/etc/environment
else
    ENV_FILE=${HOME}/.bashrc
fi

# Python configuration

if command -v pip > "$OUT" ; then
    if [[ -n "$PIP_REPOSITORY" ]]; then
        echo "configuration pip (index-url)" > "$OUT" 
        pip config set global.index-url $PIP_REPOSITORY
    fi

    if [[ -n "$PATH_TO_CA_BUNDLE" ]]; then
        echo "configuration of python and pip to use a custom crt" > "$OUT" 
        pip config set global.cert $PATH_TO_CA_BUNDLE
        python /opt/certifi_ca.py
        export REQUESTS_CA_BUNDLE=$PATH_TO_CA_BUNDLE
    fi
fi

if command -v uv > "$OUT"; then
    if [[ -n "$PIP_REPOSITORY" ]]; then
        echo "export UV_DEFAULT_INDEX=$PIP_REPOSITORY" >> "$ENV_FILE"
        echo 'export UV_NATIVE_TLS=true' >> "$ENV_FILE"   
    fi
fi

# R configuration

if command -v R > "$OUT"; then
  if [[ -n "$R_REPOSITORY" ]] || [[ -n "$PACKAGE_MANAGER_URL" ]]; then
      echo "configuration r (add local repository)" > "$OUT" 

      echo '# https://docs.rstudio.com/rspm/admin/serving-binaries/#binaries-r-configuration-linux' >> ${R_HOME}/etc/Rprofile.site
      echo 'options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(), paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))' >> ${R_HOME}/etc/Rprofile.site
      echo '# Proxy repository for R' >> ${R_HOME}/etc/Rprofile.site
      echo 'local({' >> ${R_HOME}/etc/Rprofile.site
      echo '  r <- getOption("repos")' >> ${R_HOME}/etc/Rprofile.site

      if [[ -n "$PACKAGE_MANAGER_URL" ]]; then
          UBUNTU_CODENAME=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d= -f2)
          echo "  r[\"PackageManager\"] <- \"${PACKAGE_MANAGER_URL}/${UBUNTU_CODENAME}/latest\"" >> ${R_HOME}/etc/Rprofile.site
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
