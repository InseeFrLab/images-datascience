variable "DATETIME" {
  default = "2023-04-26"
}

variable "PYTHON_VERSION_1" {
  default = "3.10.9" 
}

variable "PYTHON_VERSION_2" {
  default = "3.9.16"
}

variable "BASE_IMAGE" {
  default = "ubuntu:22.04"
}

variable "BASE_IMAGE_GPU" {
  default = "nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04"
}

VARIABLE "R_VERSION_1" {
  default = "4.2.3"
}

VARIABLE "R_VERSION_2" {
  default = "4.1.3"
}

target "base" {
  dockerfile = "base/Dockerfile"
  contexts = {
    scripts = "./scripts"
  }
  args = {
    BASE_IMAGE = "${BASE_IMAGE}"
  }
  tags = ["buildx-base:${DATETIME}", "buildx-base:latest"]
}

target "base-gpu" {
  dockerfile = "base/Dockerfile"
  contexts = {
    scripts = "./scripts"
  }
  args = {
    BASE_IMAGE = "${BASE_IMAGE_GPU}"
  }
  tags = ["buildx-base-gpu:${DATETIME}", "buildx-base-gpu:latest"]
}

target "python-minimal-1" {
  dockerfile = "python-minimal/Dockerfile"
  contexts = {
    BASE_IMAGE = "target:base"
    conda_env = "./python-minimal"
  }
  args = {
    PYTHON_VERSION = "${PYTHON_VERSION_1}"
  }
  tags = ["buildx-pythonminimal-${PYTHON_VERSION_1}:${DATETIME}", "buildx-pythonminimal-${PYTHON_VERSION_1}:latest"]
}

target "jupyter-1" {
  dockerfile = "jupyter/Dockerfile"
  contexts = {
    BASE_IMAGE = "target:python-minimal-1"
  }
  tags = ["buildx-jupyter1-${PYTHON_VERSION_1}:${DATETIME}", "buildx-jupyter1-${PYTHON_VERSION_1}:latest"]
}