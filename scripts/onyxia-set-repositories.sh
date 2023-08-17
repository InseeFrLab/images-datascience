#!/bin/bash
if [  "`which pip`" != "" ]; then
    if [[ -n "$PIP_REPOSITORY" ]]; then
        echo "configuration pip (index-url)"
        pip config set global.index-url $PIP_REPOSITORY
    fi

    if [[ -n "$PATH_TO_CA_BUNDLE" ]]; then
        echo "configuration of pip to a custom crt"
        pip config set global.cert $PATH_TO_CA_BUNDLE
    fi
fi

if [  "`which conda`" != "" ]; then
    if [[ -n "$CONDA_REPOSITORY" ]]; then
        echo "configuration conda (add channels)"
        conda config --add channels $CONDA_REPOSITORY
        conda config --remove channels conda-forge
        conda config --remove channels conda-forge --file /opt/mamba/.condarc
    fi

    if [[ -n "$PATH_TO_CA_BUNDLE" ]]; then
        echo "configuration of conda to a custom crt"
        conda config --set ssl_verify $PATH_TO_CA_BUNDLE
    fi
fi

if [  "`which python`" != "" ]; then
    python /opt/certifi_ca.py
fi

if command -v R; then
  if [[ -n "$R_REPOSITORY" ]] || [[ -n "$PACKAGE_MANAGER_URL" ]]; then
      echo "configuration r (add local repository)"

      echo '# https://docs.rstudio.com/rspm/admin/serving-binaries/#binaries-r-configuration-linux' > ${R_HOME}/etc/Rprofile.site
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

      # Unsure if this last line below should be inside this is ; 
      # leaving it here for now, but should be reviewed before.

      # Configure renv to use the specified package repository
      echo 'options(renv.config.repos.override = getOption("repos"))' >> ${R_HOME}/etc/Rprofile.site
  fi

fi
