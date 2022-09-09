import subprocess
import sys

chains = {
    "rstudio": ["base", "r-minimal", "r-datascience", "rstudio"],
    "rstudio-sparkr": ["base", "r-minimal", "spark", "rstudio"],
    "jupyter": ["base", "python-minimal", "python-datascience", "jupyter"],
    "jupyter-pyspark": ["base", "python-minimal", "spark", "jupyter"],
    "vscode": ["base", "python-minimal", "python-datascience", "vscode"],
}

chain = chains[sys.argv[1]]

for i, image in enumerate(chain):
    if image == "base":
        cmd = ["sudo", "docker", "build", image, "-t", image, "--build-arg", "BASE_IMAGE=ubuntu:20.04"]
        print(" ".join(cmd))
        subprocess.run(cmd)
    else:
        previous_image = chain[i-1]
        cmd = ["sudo", "docker", "build", image, "-t", image, "--build-arg", f"BASE_IMAGE={previous_image}"]
        print(" ".join(cmd))
        subprocess.run(cmd)
        if len(sys.argv) == 2:
            if image == sys.argv[2]:
                break
