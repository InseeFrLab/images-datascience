#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

set -e

# The _log function is used for everything this script wants to log. It will
# always log errors and warnings, but can be silenced for other messages
# by setting JUPYTER_DOCKER_STACKS_QUIET environment variable.
_log () {
    if [[ "$*" == "ERROR:"* ]] || [[ "$*" == "WARNING:"* ]] || [[ "${JUPYTER_DOCKER_STACKS_QUIET}" == "" ]]; then
        echo "$@"
    fi
}
_log "Entered start.sh with args:" "$@"

usermod --home "/home/${NB_USER}" --login "${NB_USER}" jovyan
if [[ ! -e "/home/${NB_USER}" ]]; then
    _log "Attempting to copy /home/jovyan to /home/${NB_USER}..."
    mkdir "/home/${NB_USER}"
    chown ${NB_USER}:users /home/${NB_USER}
    if cp -a /home/jovyan/. "/home/${NB_USER}/"; then
        _log "Success!"
    else
        _log "Failed to copy data from /home/jovyan to /home/${NB_USER}!"
        _log "Attempting to symlink /home/jovyan to /home/${NB_USER}..."
        if ln -s /home/jovyan "/home/${NB_USER}"; then
            _log "Success creating symlink!"
        else
            _log "ERROR: Failed copy data from /home/jovyan to /home/${NB_USER} or to create symlink!"
            exit 1
        fi
    fi
fi

if [[ "${PWD}/" == "/home/jovyan/"* ]]; then
    new_wd="/home/${NB_USER}/${PWD:13}"
    _log "Changing working directory to ${new_wd}"
    cd "${new_wd}"
fi

_log "Executing the command:" "${cmd[@]}"
exec "${@}"
