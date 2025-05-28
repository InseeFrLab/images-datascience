#!/bin/bash
set -e

# Number of retries
retries=3
# Wait time between retries
wait_time=10

# Function to install an extension with retries
install_extension() {
    local extension=$1
    local attempt=1

    while [ $attempt -le $retries ]; do
        code-server --install-extension $extension && break
        echo "Failed to install $extension. Attempt $attempt/$retries. Retrying in $wait_time seconds..."
        attempt=$((attempt + 1))
        sleep $wait_time
    done

    if [ $attempt -gt $retries ]; then
        echo "Failed to install $extension after $retries attempts."
        exit 1
    fi
}

# Install base extensions
base_extensions=(
    "ms-toolsai.jupyter"
    "ms-kubernetes-tools.vscode-kubernetes-tools"
    "mhutchie.git-graph"
    "hediet.vscode-drawio"
    "streetsidesoftware.code-spell-checker"
    "streetsidesoftware.code-spell-checker-french"
    "continue.continue"
)
for extension in "${base_extensions[@]}"; do
    install_extension $extension
done

# Python-specific configuration
python_extensions=(
    "ms-python.python"
    "ms-python.flake8"
)
if command -v python &> /dev/null; then
    for extension in "${python_extensions[@]}"; do
        install_extension $extension
    done
    python_path=$(which python)
    jq --arg pythonPath "$python_path" '.["python.defaultInterpreterPath"] = $pythonPath' ${REMOTE_CONFIG_DIR}/settings.json > tmp.json && mv tmp.json ${REMOTE_CONFIG_DIR}/settings.json
fi

# R-specific configuration
r_extensions=(
    "reditorsupport.r"
    "RDebugger.r-debugger"
)
if command -v R &> /dev/null; then
    # Install R kernel for jupyter notebooks
    if command -v pip &>/dev/null; then
        # First install the minimal jupyter-client python package to make R kernel available to jupyter notebooks
        if command -v uv &>/dev/null; then
            uv pip install --system --no-cache jupyter-client
        else
            pip install --no-cache-dir jupyter-client
        fi
        R -e "install.packages('IRkernel'); IRkernel::installspec()"
    fi
    for extension in "${r_extensions[@]}"; do
        install_extension $extension
    done
    R -e "install.packages(c('languageserver', 'rmarkdown', 'httpgd'))"
    R -e "remotes::install_github('ManuelHentschel/vscDebugger')"
    pip install radian
    r_path=$(which radian)
    jq --arg rPath "$r_path" '.["r.rterm.linux"] = $rPath' ${REMOTE_CONFIG_DIR}/settings.json > tmp.json && mv tmp.json ${REMOTE_CONFIG_DIR}/settings.json
fi

# Julia-specific configuration
if command -v julia &> /dev/null; then
    install_extension "julialang.language-julia"
fi

# Quarto-specific configuration
if command -v quarto &> /dev/null; then
    install_extension "quarto.quarto"
fi
