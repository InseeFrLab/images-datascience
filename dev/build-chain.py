import subprocess
import sys
import shutil


chains = {
    "rstudio": ["base", "r-minimal", "r-datascience", "rstudio"],
    "rstudio-sparkr": ["base", "r-minimal", "spark", "rstudio"],
    "r-minimal": ["base", "r-minimal"],
    "r-datascience": ["base", "r-minimal", "r-datascience"],
    "sparkr": ["base", "r-minimal", "spark"],
    "python-minimal": ["base", "python-minimal"],
    "python-datascience": ["base", "python-minimal", "python-datascience"],
    "python-pytorch": ["base", "python-minimal", "python-pytorch"],
    "python-tensorflow": ["base", "python-minimal", "python-tensorflow"],
    "python-pyspark": ["base", "python-minimal", "spark"],
    "jupyter-r": ["base", "r-minimal", "r-datascience", "jupyter"],
    "jupyter-minimal": ["base", "python-minimal", "jupyter"],
    "jupyter-datascience": ["base", "python-minimal", "python-datascience", "jupyter"],
    "jupyter-pytorch": ["base", "python-minimal", "python-pytorch", "jupyter"],
    "jupyter-tensorflow": ["base", "python-minimal", "python-tensorflow", "jupyter"],
    "jupyter-pyspark": ["base", "python-minimal", "spark", "jupyter"],
    "vscode-python": ["base", "python-minimal", "python-datascience", "vscode"],
    "vscode-python-minimal": ["base", "python-minimal", "vscode"],
    "r-python-julia": ["base", "r-minimal", "r-python-julia"],
    "vscode-r-python-julia": ["base", "r-minimal", "r-python-julia", "vscode"],
    "vscode-r": ["base", "r-minimal", "r-datascience", "vscode"]
}

chain_name = sys.argv[1]
chain = chains[chain_name]

# GPU build if third argument says so
GPU = len(sys.argv) >= 3 and sys.argv[2] == "gpu"

# Specific R/Python version specified in fourth argument
version = sys.argv[3] if len(sys.argv) >= 4 else None
language_key = "PYTHON_VERSION" if "python-minimal" in chain else "R_VERSION"

for i, image in enumerate(chain):

    if image == "base":
        shutil.copytree("scripts", "base/scripts", dirs_exist_ok=True)
        if GPU:
            previous_image = "nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04"
        else:
            previous_image = "ubuntu:22.04"
    else:
        previous_image = chain[i-1]

    device_suffix = "-gpu" if GPU else ""

    if i < len(chain) - 1:
        tag = image
    else:
        tag = f"inseefrlab/onyxia-{chain_name}:dev"

    cmd = ["docker", "build", "--progress=plain", image, "-t", tag,
           "--build-arg", f"BASE_IMAGE={previous_image}",
           "--build-arg", f"DEVICE_SUFFIX={device_suffix}"]
    if version:
        cmd.extend(["--build-arg", f"{language_key}={version}"])

    print(" ".join(cmd))
    subprocess.run(cmd)
