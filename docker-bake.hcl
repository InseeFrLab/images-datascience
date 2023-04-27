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

variable "R_VERSION_1" {
  default = "4.2.3"
}

variable "R_VERSION_2" {
  default = "4.1.3"
}

target "base" {
  dockerfile = "base/Dockerfile"
  contexts = {
    scripts = "./scripts"
  }
  cache-to = ["type=gha,mode=max"]
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
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
  args = {
    BASE_IMAGE = "${BASE_IMAGE_GPU}"
  }
  tags = ["buildx-base-gpu:${DATETIME}", "buildx-base-gpu:latest"]
}

target "python-minimal-1" {
  dockerfile = "python-minimal/Dockerfile"
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
  contexts = {
    base_image = "target:base-gpu"
    conda_env = "./python-minimal"
  }
  args = {
    PYTHON_VERSION = "${PYTHON_VERSION_1}"
  }
  tags = ["buildx-pythonminimal-${PYTHON_VERSION_1}:${DATETIME}", "buildx-pythonminimal-${PYTHON_VERSION_1}:latest"]
}

target "pytorch-1" {
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
  dockerfile = "python-pytorch/Dockerfile"
  contexts = {
    base_image = "target:python-minimal-1"
  }
  tags = ["buildx-pytorch1-${PYTHON_VERSION_1}:${DATETIME}", "buildx-pytorch1-${PYTHON_VERSION_1}:latest"]
}

target "jupyter-pytorch-1" {
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
  dockerfile = "jupyter/Dockerfile"
  contexts = {
    base_image = "target:pytorch-1"
  }
  tags = ["buildx-jupyter-pytorch1-${PYTHON_VERSION_1}:${DATETIME}", "buildx-jupyter-pytorch1-${PYTHON_VERSION_1}:latest"]
}

target "r-minimal-1" {
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
  dockerfile = "r-minimal/Dockerfile"
  contexts = {
    base_image = "target:base"
  }
  args = {
    R_VERSION = "${R_VERSION_1}"
  }
  tags = ["buildx-r-minimal-${R_VERSION_1}:${DATETIME}", "buildx-r-minimal-${R_VERSION_1}:latest"]
}

target "r-datascience-1" {
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
  dockerfile = "r-datascience/Dockerfile"
  contexts = {
    base_image = "target:r-minimal-1"
  }
  tags = ["buildx-r-datascience-${R_VERSION_1}:${DATETIME}", "buildx-r-datascience-${R_VERSION_1}:latest"]
}

target "jupyter-r-1" {
  cache-from = ["type=gha"]
  dockerfile = "jupyter/Dockerfile"
  contexts = {
    base_image = "target:r-datascience-1"
  }
  tags = ["buildx-jupyter-r-${R_VERSION_1}:${DATETIME}", "buildx-jupyter-r-${R_VERSION_1}:latest"]
}

target "r-minimal-2" {
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
  dockerfile = "r-minimal/Dockerfile"
  contexts = {
    base_image = "target:base"
  }
  args = {
    R_VERSION = "${R_VERSION_2}"
  }
  tags = ["buildx-r-minimal-${R_VERSION_2}:${DATETIME}", "buildx-r-minimal-${R_VERSION_2}:latest"]
}

target "r-datascience-2" {
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
  dockerfile = "r-datascience/Dockerfile"
  contexts = {
    base_image = "target:r-minimal-2"
  }
  tags = ["buildx-r-datascience-${R_VERSION_2}:${DATETIME}", "buildx-r-datascience-${R_VERSION_2}:latest"]
}

target "jupyter-r-2" {
  cache-from = ["type=gha"]
  dockerfile = "jupyter/Dockerfile"
  contexts = {
    base_image = "target:r-datascience-2"
  }
  tags = ["buildx-jupyter-r-${R_VERSION_2}:${DATETIME}", "buildx-jupyter-r-${R_VERSION_2}:latest"]
}
