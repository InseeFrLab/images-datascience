import subprocess
import sys


chains = {
    "rstudio": ["base", "r-minimal", "r-datascience", "rstudio"],
    "rstudio-sparkr": ["base", "r-minimal", "spark", "rstudio"],
    "jupyter-r": ["base", "r-minimal", "r-datascience", "jupyter-r"],
    "jupyter-python": ["base", "python-minimal", "python-datascience",
                       "jupyter-python"],
    "jupyter-pyspark": ["base", "python-minimal", "spark", "jupyter"],
    "vscode": ["base", "python-minimal", "python-datascience", "vscode"],
    "vscode_minimal": ["base", "python-minimal", "vscode"]
}

chain = chains[sys.argv[1]]

GPU = False
if len(sys.argv) == 3:
    if sys.argv[2] == "gpu":
        GPU = True

for i, image in enumerate(chain):

    if image == "base":
        previous_image = "ubuntu:20.04"
    else:
        previous_image = chain[i-1]

    if GPU:
        device_suffix = "-gpu"
    else:
        device_suffix = ""

    cmd = ["sudo", "docker", "build", image, "-t", image,
           "--build-arg", f"BASE_IMAGE={previous_image}",
           "--build-arg", f"DEVICE_SUFFIX={device_suffix}"]
    print(" ".join(cmd))
    subprocess.run(cmd)
