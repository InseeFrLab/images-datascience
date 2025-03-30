import argparse
import subprocess
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
    "vscode-r": ["base", "r-minimal", "r-datascience", "vscode"],
}


# CLI configuration
parser = argparse.ArgumentParser(description="Build a Docker image chain.")
parser.add_argument(
    "--chain",
    required=True,
    choices=chains.keys(),
    help="The name of the chain to build (e.g., 'rstudio', 'python-datascience').",
)
parser.add_argument(
    "--gpu",
    action="store_true",
    help="Whether to build with GPU support."
)
parser.add_argument(
    "--version",
    help="Specify a version for R or Python."
)
parser.add_argument(
    "--no_cache",
    action="store_true",
    help="Tell Docker to build without using caching."
)

if __name__ == "__main__":

    # Parse build configuration from CLI args
    args = parser.parse_args()
    chain_name = args.chain
    chain = chains[chain_name]
    gpu = args.gpu
    version = args.version
    no_cache = args.no_cache
    language_key = "PYTHON_VERSION" if "python-minimal" in chain else "R_VERSION"

    # Build chain
    for i, image in enumerate(chain):
        if image == "base":
            shutil.copytree("scripts", "base/scripts", dirs_exist_ok=True)
            previous_image = "nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04" if gpu else "ubuntu:22.04"
        else:
            previous_image = chain[i - 1]

        device_suffix = "-gpu" if gpu else ""

        if i < len(chain) - 1:
            tag = image
        else:
            tag = f"inseefrlab/onyxia-{chain_name}:dev"

        cmd = [
            "docker", "build", "--progress=plain", image, "-t", tag,
            "--build-arg", f"BASE_IMAGE={previous_image}",
            "--build-arg", f"DEVICE_SUFFIX={device_suffix}"
        ]
        if version:
            cmd.extend(["--build-arg", f"{language_key}={version}"])
        if no_cache:
            cmd.extend(["--no-cache"])

        print(" ".join(cmd))
        subprocess.run(cmd, check=True)
