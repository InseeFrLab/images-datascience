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


def build_chain(chain_name, r_version, py_version, spark_version,
                gpu, no_cache, push):

    logging.info(f"Building chain : {chain_name}")
    chain = chains[chain_name]

    for i, image in enumerate(chain):

        # Placeholder for build args
        build_args = []

        # Specify base image for each build step
        if i == 0:
            # First step : define external base images
            shutil.copytree("scripts", "base/scripts", dirs_exist_ok=True)
            previous_image = "nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04" if gpu else "ubuntu:22.04"
        else:
            # Intermediary and final steps : use previous built tag as base image 
            previous_image = tag
        build_args.extend(["--build-arg", f"BASE_IMAGE={previous_image}"])

        # Specify language versions
        versions_tag = []
        if r_version is not None:
            build_args.extend(["--build-arg", f"R_VERSION={r_version}"])
            versions_tag.append(f"r{r_version}")
        if py_version is not None:
            build_args.extend(["--build-arg", f"PYTHON_VERSION={py_version}"])
            versions_tag.append(f"py{py_version}")
        if spark_version is not None:
            build_args.extend(["--build-arg", f"SPARK_VERSION={spark_version}"])
            versions_tag.append(f"spark{spark_version}")

        # Output tag
        if i == 0:
            # First step : base is always tagged as latest
            tag = "inseefrlab/onyxia-base:latest"
        else:
            # Intermediary and final steps : tag with language versions
            # If final step, image is named after chain_name
            image_name = image if i < len(chain) - 1 else chain_name
            versions_tag_str = "-".join(versions_tag)
            tag = f"inseefrlab/onyxia-{image_name}:{versions_tag_str}"
        if gpu:
            tag += "-gpu"
        tag += "-dev"

        cmd_build = [
            "docker", "build", "--progress=plain", image, "-t", tag,
            "--build-arg", f"BASE_IMAGE={previous_image}"
        ]
        if no_cache:
            cmd_build.extend(["--no-cache"])

        logging.info(f"Build command : {' '.join(cmd_build)}")
        subprocess.run(cmd_build, check=True)

        # Container tests
        cmd_test = ["container-structure-test", "test", "--image", tag,
                    "--config", f"{image}/tests.yaml"]
        logging.info(f"Test command : {cmd_test}")
        subprocess.run(cmd_test, check=True)

    if push:
        cmd_push = ["docker", "push", tag]
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
        "--r_version",
        help="Specify a version for R."
    )
    parser.add_argument(
        "--py_version",
        help="Specify a version for Python."
    )
    parser.add_argument(
        "--spark_version",
        help="Specify a version for Spark."
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

    # Build chain
    build_chain(chain_name=args.chain,
                r_version=args.r_version,
                py_version=args.py_version,
                spark_version=args.spark_version,
                gpu=args.gpu,
                no_cache=args.no_cache,
                push=args.push
                )
