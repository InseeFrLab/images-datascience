#!/bin/bash
set -e

RSTUDIO_SYSTEM_CONF_FILE="/etc/rstudio/rsession.conf"
RSTUDIO_USER_CONF_FILE="${HOME}/.config/rstudio/rstudio-prefs.json"

# Set default working directory for R sessions and R projects
echo "session-default-working-dir=${WORKSPACE_DIR}" >> ${RSTUDIO_SYSTEM_CONF_FILE}
echo "session-default-new-project-dir=${WORKSPACE_DIR}" >> ${RSTUDIO_SYSTEM_CONF_FILE}

# Initialize RStudio's user config file
RSTUDIO_USER_CONF_DIR="$(dirname $RSTUDIO_USER_CONF_FILE)"
mkdir -p $RSTUDIO_USER_CONF_DIR
echo '{}' > $RSTUDIO_USER_CONF_FILE

# Give user ownership on user config directory
chown -R ${USERNAME}:${GROUPNAME} $RSTUDIO_USER_CONF_DIR
