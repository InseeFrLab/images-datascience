#!/usr/bin/env bash
if [  "`which pip`" != "" ]; then
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

