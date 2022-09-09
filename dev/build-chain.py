import subprocess
import sys

chains = {
    "r": ["base", "r-minimal", "r-datascience", "rstudio"],
    "python": ["base", "python-minimal", "python-datascience", "jupyter"]
}

chain = chains[sys.argv[1]]

for i, image in enumerate(chain):
    if image == "base":
        subprocess.run(["docker", "build", image, "-t", image, "--build-arg", f"BASE_IMAGE=ubuntu:20.04"])
    else:
        previous_image = chain[i-1]
        subprocess.run(["docker", "build", image, "-t", image, "--build-arg", f"BASE_IMAGE={previous_image}"])
        if len(sys.argv == 2) and image == sys.argv[2]:
            break
