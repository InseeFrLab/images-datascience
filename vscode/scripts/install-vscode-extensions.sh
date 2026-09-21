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
    "continue.continue@1.3.38"
    "sst-dev.opencode"
)
for extension in "${base_extensions[@]}"; do
    install_extension $extension
done

# Python-specific configuration
python_extensions=(
    "ms-python.python"
    "ms-python.flake8"
    "charliermarsh.ruff"
)
if command -v python &> /dev/null; then
    for extension in "${python_extensions[@]}"; do
        install_extension $extension
    done
    # ms-python.python is an extension pack that pulls in ms-python.vscode-python-envs,
    # which shells out to the native "pet" locator bundled only in the platform-specific
    # builds of ms-python.python. Open VSX only publishes the universal build, so pet is
    # missing and the extension pops up a recurring "Default interpreter path could not be
    # resolved" warning. ms-python.python locates interpreters on its own, so drop it.
    # See https://github.com/microsoft/vscode-python/issues/25820
    if code-server --list-extensions | grep -qx "ms-python.vscode-python-envs"; then
        code-server --uninstall-extension ms-python.vscode-python-envs
    fi
    python_path=$(which python)
    jq --arg pythonPath "$python_path" '.["python.defaultInterpreterPath"] = $pythonPath' ${REMOTE_CONFIG_DIR}/settings.json > tmp.json && mv tmp.json ${REMOTE_CONFIG_DIR}/settings.json
fi

# R-specific configuration
r_extensions=(
    "reditorsupport.r"
    "RDebugger.r-debugger"
    "Posit.air-vscode"
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
    R -e "install.packages(c('remotes', 'languageserver', 'rmarkdown', 'httpgd'))"
    R -e "install.packages('vscDebugger', repos = c('https://manuelhentschel.r-universe.dev', getOption('repos')))"
fi

# Julia-specific configuration
if command -v julia &> /dev/null; then
    install_extension "julialang.language-julia"
fi

# Quarto-specific configuration
if command -v quarto &> /dev/null; then
    install_extension "quarto.quarto"
fi
