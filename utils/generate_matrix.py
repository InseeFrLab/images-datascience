"""Generate the matrix for each job of the build pipeline."""

import argparse
import json
import os
from datetime import UTC, datetime
from pathlib import Path

DH_ORGA = "inseefrlab"
IMAGES_PREFIX = "onyxia"
TODAY_DATE = datetime.now(UTC).strftime("%Y.%m.%d")
VERSIONS_FILE = "versions.env"


def generate_matrix(versions, input_image, output_image, spark_version, gpu_options, version_prefix):
    """
    Generate the build matrix for the given versions and options.

    Args:
        versions (list): A list of version strings (Python or R versions).
        input_image (str): The base image name.
        output_image (str): The output image name.
        spark_version (str): The Spark version to include in the output image tag.
        gpu_options (list): A list of booleans indicating whether to build GPU-enabled images.
        version_prefix (str): A prefix to denote the language version ("py" or "r").

    Returns:
        list: A list of dictionaries, each representing a build configuration.
    """
    matrix = []
    for version in versions:
        base = f"{input_image}:latest" if input_image == "base" else f"{input_image}:{version_prefix}{version}"
        output = f"{output_image}:{version_prefix}{version}"
        language_key = "python_version" if version_prefix == "py" else "r_version"
        version_entry = {
            "base_image_tag": f"{DH_ORGA}/{IMAGES_PREFIX}-{base}",
            "output_image_main_tag": f"{DH_ORGA}/{IMAGES_PREFIX}-{output}",
            language_key: version,
        }
        if spark_version:
            suffix_spark = f"-spark{spark_version}"
            if "spark" in base:
                version_entry["base_image_tag"] += suffix_spark
            version_entry["output_image_main_tag"] += suffix_spark
            version_entry["spark_version"] = spark_version
        for gpu in gpu_options:
            final_entry = version_entry.copy()
            suffix_gpu = "-gpu" if gpu else ""
            final_entry["base_image_tag"] += suffix_gpu
            final_entry["output_image_main_tag"] += suffix_gpu
            final_entry["output_image_tags"] = (
                f"{final_entry['output_image_main_tag']},{final_entry['output_image_main_tag']}-{TODAY_DATE}"
            )
            matrix.append(final_entry)
    return matrix


def generate_r_python_julia_matrix(r_version, py_version, input_image, output_image):
    matrix = []
    if "r-datascience" in input_image:
        # r-python-julia inherits from r-datascience
        base = f"{input_image}:r{r_version}"
    else:
        # {jupyter/vscode}-r-python-julia inherit from r-python-julia
        base = f"{input_image}:r{r_version}-py{py_version}"
    output = f"{output_image}:r{r_version}-py{py_version}"
    final_entry = {
        "base_image_tag": f"{DH_ORGA}/{IMAGES_PREFIX}-{base}",
        "output_image_main_tag": f"{DH_ORGA}/{IMAGES_PREFIX}-{output}",
        "r_version": r_version,
        "python_version": py_version,
    }
    final_entry["output_image_tags"] = (
        f"{final_entry['output_image_main_tag']},{final_entry['output_image_main_tag']}-{TODAY_DATE}"
    )
    matrix.append(final_entry)
    return matrix


def read_versions():
    """Parse the KEY="value" lines of versions.env into a dict, ignoring comments and blank lines."""
    versions = {}
    for line in Path(VERSIONS_FILE).read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            key, value = line.split("=", 1)
            versions[key] = value.strip('"')
    return versions


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--input_image", type=str)
    parser.add_argument("--output_image", type=str)
    parser.add_argument("--languages", type=str, choices=["", "python", "r", "r-python"], default="")
    parser.add_argument("--spark", type=str, default="false")
    parser.add_argument("--build_gpu", type=str, nargs="?")

    args = parser.parse_args()
    versions = read_versions()
    python_versions = [versions["PYTHON_VERSION_1"], versions["PYTHON_VERSION_2"]]
    r_versions = [versions["R_VERSION_1"], versions["R_VERSION_2"]]
    spark_version = versions["SPARK_VERSION"] if args.spark == "true" else ""
    gpu_options = [False, True] if args.build_gpu == "true" else [False]

    if args.output_image == "base":
        # Building base onyxia image from external images
        onyxia_base_tag = f"{IMAGES_PREFIX}-base:latest"
        matrix = [
            {
                "base_image_tag": versions["BASE_IMAGE_CPU"],
                "output_image_main_tag": f"{DH_ORGA}/{onyxia_base_tag}",
                "output_image_tags": f"{DH_ORGA}/{onyxia_base_tag},{DH_ORGA}/{onyxia_base_tag}-{TODAY_DATE}",
            },
            {
                "base_image_tag": versions["BASE_IMAGE_GPU"],
                "output_image_main_tag": f"{DH_ORGA}/{onyxia_base_tag}-gpu",
                "output_image_tags": f"{DH_ORGA}/{onyxia_base_tag}-gpu,{DH_ORGA}/{onyxia_base_tag}-gpu-{TODAY_DATE}",
            },
        ]

    elif args.languages == "r-python":
        # Multi-language images are only built with the newest versions of R and Python
        matrix = generate_r_python_julia_matrix(
            r_version=r_versions[0],
            py_version=python_versions[0],
            input_image=args.input_image,
            output_image=args.output_image,
        )

    else:
        # Other images have either R or Python versions
        matrix = generate_matrix(
            python_versions if args.languages == "python" else r_versions,
            args.input_image,
            args.output_image,
            spark_version,
            gpu_options,
            "py" if args.languages == "python" else "r",
        )

    print(matrix)

    # Dump matrix in GHA env file
    payload = {"include": matrix}
    with open(os.environ["GITHUB_OUTPUT"], "a") as fh:
        fh.write(f"matrix={json.dumps(payload)}\n")
