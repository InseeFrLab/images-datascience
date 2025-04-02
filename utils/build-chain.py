import argparse
import subprocess
import shutil
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)

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
    "jupyter-python-minimal": ["base", "python-minimal", "jupyter"],
    "jupyter-python": ["base", "python-minimal", "python-datascience", "jupyter"],
    "jupyter-pytorch": ["base", "python-minimal", "python-pytorch", "jupyter"],
    "jupyter-tensorflow": ["base", "python-minimal", "python-tensorflow", "jupyter"],
    "jupyter-pyspark": ["base", "python-minimal", "spark", "jupyter"],
    "vscode-python": ["base", "python-minimal", "python-datascience", "vscode"],
    "vscode-python-minimal": ["base", "python-minimal", "vscode"],
    "vscode-pytorch": ["base", "python-minimal", "python-pytorch", "vscode"],
    "vscode-tensorflow": ["base", "python-minimal", "python-tensorflow", "vscode"],
    "r-python-julia": ["base", "r-minimal", "r-python-julia"],
    "jupyter-r-python-julia": ["base", "r-minimal", "r-python-julia", "jupyter"],
    "vscode-r-python-julia": ["base", "r-minimal", "r-python-julia", "vscode"],
    "vscode-r": ["base", "r-minimal", "r-datascience", "vscode"]
}


def build_chain(chain_name, language_key, version, gpu, no_cache, push):

    logging.info(f"Building chain : {chain_name}")
    chain = chains[chain_name]

    for i, image in enumerate(chain):
        if image == "base":
            shutil.copytree("scripts", "base/scripts", dirs_exist_ok=True)
            previous_image = "nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04" if gpu else "ubuntu:22.04"
        else:
            previous_image = chain[i - 1]

        if i < len(chain) - 1:
            tag = image
        else: 
            # Last step of the chain
            tag = f"inseefrlab/onyxia-{chain_name}:dev"

        cmd_build = [
            "docker", "build", "--progress=plain", image, "-t", tag,
            "--build-arg", f"BASE_IMAGE={previous_image}"
        ]
        if version:
            version_param = "PYTHON_VERSION" if language_key == "py" else "R_VERSION"
            cmd_build.extend(["--build-arg", f"{version_param}={version}"])
        if no_cache:
            cmd_build.extend(["--no-cache"])

        logging.info(f"Build command : {' '.join(cmd_build)}")
        subprocess.run(cmd_build, check=True)

    if push:
        push_tag = f"inseefrlab/onyxia-{chain_name}:{language_key}{version}-dev"
        cmd_tag = ["docker", "tag", tag, push_tag]
        cmd_push = ["docker", "push", push_tag]
        logging.info(f"Push command : {cmd_push}")
        subprocess.run(cmd_push, check=True)


def build_cli_parser():
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
    parser.add_argument(
        "--push",
        action="store_true",
        help="Whether to push the last image of the chain to DockerHub."
    )
    return parser


if __name__ == '__main__':

    # Parse CLI parameters
    parser = build_cli_parser()
    args = parser.parse_args()
    language_key = "py" if "python-minimal" in chains[args.chain] else "r"

    # Build chain
    build_chain(chain_name=args.chain,
                language_key=language_key,
                version=args.version,
                gpu=args.gpu,
                no_cache=args.no_cache,
                push=args.push
                )
