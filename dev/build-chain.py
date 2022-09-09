import subprocess
import sys

chains = {
    "r": ["base", "r-minimal", "r-datascience", "rstudio"],
    "python": ["base", "python-minimal", "python-datascience", "jupyter"]
}

chain = chains[sys.argv[1]]

for i, image in enumerate(chain):
    if image == "base":
        cmd = ["docker", "build", image, "-t", image, "--build-arg", "BASE_IMAGE=ubuntu:20.04"]
        print(" ".join(cmd))
        subprocess.run(cmd)
    else:
        previous_image = chain[i-1]
        cmd = ["docker", "build", image, "-t", image, "--build-arg", f"BASE_IMAGE={previous_image}"]
        print(" ".join(cmd))
        subprocess.run(cmd)
        if len(sys.argv == 2) and image == sys.argv[2]:
            break
