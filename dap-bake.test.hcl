# The master group that runs when you invoke bake without targeting a specific image
group "default" {
  targets = ["onyxia-vscode-python"]
}

target "onyxia-base" {
  context    = "./base"
  dockerfile = "Dockerfile"
  tags       = ["inseefrlab/onyxia-base:latest"]
  args = {
    INSTALL_ALL = "false"
  }
}

target "onyxia-python-minimal" {
  context    = "./python-minimal"
  dockerfile = "Dockerfile"
  tags       = ["inseefrlab/onyxia-python-minimal:latest"]
  args = {
    INSTALL_CLIENT_DUCKDB = "false"
  }
  # This maps the FROM clause in this target's Dockerfile to the output of onyxia-base
  contexts = {
    "inseefrlab/onyxia-base" = "target:onyxia-base"
  }
}

target "onyxia-python-datascience" {
  context    = "./python-datascience"
  dockerfile = "Dockerfile"
  tags       = ["inseefrlab/onyxia-python-datascience:latest"]
  contexts = {
    "inseefrlab/onyxia-python-minimal" = "target:onyxia-python-minimal"
  }
}

target "onyxia-vscode-python" {
  context    = "./vscode"
  dockerfile = "Dockerfile"
  tags       = ["inseefrlab/onyxia-vscode-python:latest"]
  contexts = {
    "inseefrlab/onyxia-python-datascience" = "target:onyxia-python-datascience"
  }
}

target "dscc-vscode-python-flat" {
  context    = "./dap-images"
  dockerfile = "vscode.Dockerfile"
  tags       = ["dsccadminch/onyxia-vscode-python-flat:latest"]
  contexts = {
    "inseefrlab/onyxia-vscode-python" = "target:onyxia-vscode-python"
  }
  # This tells BuildKit to intercept the final image and squash all 
  # newly created layers into a single layer before saving it to your Docker daemon.
  output     = ["type=docker,squash=true"]
}