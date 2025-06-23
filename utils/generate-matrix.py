"""Generate the matrix for each job of the build pipeline."""
import json
import argparse
from datetime import datetime


def generate_matrix(versions, input_image, output_image, spark_version,
                    gpu_options, version_prefix):
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
        version_entry = {"base_image_tag": f"{DH_ORGA}/{args.images_prefix}-{base}",
                         "output_image_main_tag": f"{DH_ORGA}/{args.images_prefix}-{output}",
                         language_key: version}
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
            final_entry["output_image_tags"] = f'{final_entry["output_image_main_tag"]},{final_entry["output_image_main_tag"]}-{TODAY_DATE}'
            matrix.append(final_entry)
    return matrix


def generate_r_python_julia_matrix(r_version, py_version,
                                   input_image, output_image):
    matrix = []
    if "r-datascience" in input_image:
        # r-python-julia inherits from r-datascience
        base = f"{input_image}:r{r_version}"
    else:
        # {jupyter/vscode}-r-python-julia inherit from r-python-julia
        base = f"{input_image}:r{r_version}-py{py_version}"
    output = f"{output_image}:r{r_version}-py{py_version}"
    final_entry = {"base_image_tag": f"{DH_ORGA}/{args.images_prefix}-{base}",
                   "output_image_main_tag": f"{DH_ORGA}/{args.images_prefix}-{output}",
                   "r_version": r_version,
                   "python_version": py_version
                   }
    final_entry["output_image_tags"] = f'{final_entry["output_image_main_tag"]},{final_entry["output_image_main_tag"]}-{TODAY_DATE}'
    matrix.append(final_entry)
    return matrix


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--input_image", type=str)
    parser.add_argument("--output_image", type=str)
    parser.add_argument("--python_version_1", type=str, nargs="?", const="")
    parser.add_argument("--python_version_2", type=str, nargs="?", const="")
    parser.add_argument("--r_version_1", type=str, nargs="?", const="")
    parser.add_argument("--r_version_2", type=str, nargs="?", const="")
    parser.add_argument("--spark_version", type=str, nargs="?", const="")
    parser.add_argument("--build_gpu", type=str, nargs="?")
    parser.add_argument("--base_image_gpu", type=str, nargs="?", const="")
    parser.add_argument("--dh_orga", type=str)
    parser.add_argument("--images_prefix", type=str)

    args = parser.parse_args()
    python_versions = [version for version in [args.python_version_1, args.python_version_2]
                       if version]
    r_versions = [version for version in [args.r_version_1, args.r_version_2] if version]
    gpu_options = [False, True] if args.build_gpu == "true" else [False]

    DH_ORGA = args.dh_orga.lower()
    TODAY_DATE = datetime.today().strftime('%Y.%m.%d')

    if args.output_image == "base":
        # Building base onyxia image from external images
        onyxia_base_tag = f"{args.images_prefix}-base:latest"
        matrix = [
            {
                "base_image_tag": args.input_image,
                "output_image_main_tag": f"{DH_ORGA}/{onyxia_base_tag}",
                "output_image_tags": f"{DH_ORGA}/{onyxia_base_tag},{DH_ORGA}/{onyxia_base_tag}-{TODAY_DATE}"
            },
            {
                "base_image_tag": args.base_image_gpu,
                "output_image_main_tag": f"{DH_ORGA}/{onyxia_base_tag}-gpu",
                "output_image_tags": f"{DH_ORGA}/{onyxia_base_tag}-gpu,{DH_ORGA}/{onyxia_base_tag}-gpu-{TODAY_DATE}"
            }
            ]

    elif "r-python-julia" in args.output_image:
        # Building multi-languages image
        matrix = generate_r_python_julia_matrix(r_version=r_versions[0],
                                                py_version=python_versions[0],
                                                input_image=args.input_image,
                                                output_image=args.output_image)

    else:
        # Other images have either R or Python versions
        if python_versions:
            matrix = generate_matrix(python_versions, args.input_image, args.output_image,
                                     args.spark_version, gpu_options, "py")
        elif r_versions:
            matrix = generate_matrix(r_versions, args.input_image, args.output_image,
                                     args.spark_version, gpu_options, "r")

    matrix_json = json.dumps(matrix)
    print(matrix_json)
