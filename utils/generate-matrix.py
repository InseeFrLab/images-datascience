"""Generate the matrix for each job of the build pipeline."""
import json
import argparse


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
        version_prefix (str): A prefix to denote the language version (e.g., "py" for Python, "r" for R).

    Returns:
        list: A list of dictionaries, each representing a build configuration.
    """
    matrix = []
    for version in versions:
        base = f"{input_image}:latest" if input_image == "base" else f"{input_image}:{version_prefix}{version}"
        output = f"{output_image}:{version_prefix}{version}"
        language_key = "python_version" if version_prefix == "py" else "r_version"
        version_entry = {"base_image": base, "output_image": output, language_key: version}
        if spark_version:
            version_entry["output_image"] += f"-spark{spark_version}"
            version_entry["spark_version"] = spark_version
        for gpu in gpu_options:
            suffix = "-gpu" if gpu else ""
            version_entry["base_image"] += suffix
            version_entry["output_image"] += suffix
            matrix.append(version_entry)
    return matrix


if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--input_image", type=str)
    parser.add_argument("--output_image", type=str)
    parser.add_argument("--python_version1", type=str, nargs="?", const="")
    parser.add_argument("--python_version2", type=str, nargs="?", const="")
    parser.add_argument("--r_version1", type=str, nargs="?", const="")
    parser.add_argument("--r_version2", type=str, nargs="?", const="")
    parser.add_argument("--spark_version", type=str, nargs="?", const="")
    parser.add_argument("--build_gpu", type=str, nargs="?", const="true")
    parser.add_argument("--base_image_gpu", type=str)

    args = parser.parse_args()

    python_versions = [version for version in [args.python_version1, args.python_version2]
                       if version]
    r_versions = [version for version in [args.r_version1, args.r_version2] if version]
    gpu_options = [False, True] if args.build_gpu == "true" else [False]

    if args.output_image == "base":
        # Building base onyxia image from external images
        matrix = [
            {"base_image": args.input_image, "output_image": "base:latest"},
            {"base_image": args.base_image_gpu, "output_image": "base:latest-gpu"}
            ]
    else:
        # Subsequent images, with versioning
        if python_versions:
            matrix = generate_matrix(python_versions, args.input_image, args.output_image,
                                     args.spark_version, gpu_options, "py")
        elif r_versions:
            matrix = generate_matrix(r_versions, args.input_image, args.output_image,
                                     args.spark_version, gpu_options, "r")

    matrix_json = json.dumps(matrix)
    print(matrix_json)
