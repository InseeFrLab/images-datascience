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
    "vscode": ["base", "python-minimal", "python-datascience", "vscode"],
    "vscode-minimal": ["base", "python-minimal", "vscode"],
    "r-python-julia": ["base", "r-minimal", "r-python-julia"],
    "vscode-r-python-julia": ["base", "r-minimal", "r-python-julia", "vscode"]
}

chain = chains[sys.argv[1]]

GPU = False
if len(sys.argv) == 3:
    if sys.argv[2] == "gpu":
        GPU = True

for i, image in enumerate(chain):

    if image == "base":
        shutil.copytree("scripts", "base/scripts", dirs_exist_ok=True)
        if GPU:
            previous_image = "nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04"
        else:
            previous_image = "ubuntu:22.04"
    else:
        previous_image = chain[i-1]

    if GPU:
        device_suffix = "-gpu"
    else:
        device_suffix = ""

    cmd = ["docker", "build", image, "-t", image,
           "--build-arg", f"BASE_IMAGE={previous_image}",
           "--build-arg", f"DEVICE_SUFFIX={device_suffix}"]
    print(" ".join(cmd))
    subprocess.run(cmd)
