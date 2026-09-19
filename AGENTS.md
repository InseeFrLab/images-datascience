# AGENTS.md

## What this repo is

Docker images for ready-to-run datascience services (Jupyter, RStudio, VSCode, marimo…), designed in particular for [Onyxia](https://github.com/InseeFrLab/onyxia-web) based data-science platforms and published to Docker Hub as `inseefrlab/onyxia-<image>:<tag>`. Most of the "code" is Dockerfiles and bash install scripts; the Python in `src/` only orchestrates builds.

## Commands

Python tooling (Python version in `.python-version`, managed with uv):

```bash
uv sync                                                    # install dev deps (ruff, shellcheck, hadolint)
uv run ruff check .                                        # lint Python (line-length 120, set in pyproject.toml)
uv run ruff format .                                       # format Python
uv run shellcheck --severity=warning $(git ls-files '*.sh')  # lint shell scripts
uv run hadolint $(git ls-files '*Dockerfile')              # lint Dockerfiles (config in .hadolint.yaml)
```

These same checks run on every PR in `.github/workflows/check-code-quality.yml`, and they must pass. Images are deliberately **not** built on PRs: it was tried and costs too much compute. Image builds only happen in the weekly/manual `main-workflow.yml`.

Build a full image chain locally (each layer is built with `docker build`, then tested with `container-structure-test`, which must be installed):

```bash
python3 src/images_datascience/build_chain.py --chain jupyter-python --py_version 3.13.15
python3 src/images_datascience/build_chain.py --chain rstudio --r_version 4.6.1
python3 src/images_datascience/build_chain.py --chain jupyter-pyspark --py_version 3.13.15 --spark_version 4.1.1
# flags: --gpu (start from nvidia/cuda base), --no_test, --push
```

Local tags get a `-dev` suffix (e.g. `inseefrlab/onyxia-python-minimal:py3.13.15-dev`). `src/images_datascience/build_chains.sh` builds a representative set of chains.

Test a single already-built image against one layer's tests:

```bash
container-structure-test test --image <tag> --config <layer-dir>/tests.yaml
```

There are no unit tests; image validation is entirely via each layer's `tests.yaml` (Google Container Structure Test).

## Architecture

### Layered images via `BASE_IMAGE`

Each top-level directory (`base`, `python-minimal`, `r-minimal`, `python-datascience`, `r-datascience`, `python-pytorch`, `spark`, `r-python-julia`, `jupyter`, `rstudio`, `vscode`, `marimo`) is a **build context for one layer**, not a final image. Every Dockerfile starts with `ARG BASE_IMAGE` / `FROM $BASE_IMAGE`, so the same layer is stacked onto different parents to produce different final images:

- `base` ← `ubuntu:24.04` or `nvidia/cuda:*-cudnn-devel-ubuntu24.04` (GPU variants)
- `python-minimal` / `r-minimal` ← `base`
- `python-datascience`, `python-pytorch`, `r-datascience`, `r-python-julia`, `spark` ← a minimal image
- IDE layers `jupyter`, `vscode`, `rstudio`, `marimo` ← any of the above

Because layers are reused across parents, their Dockerfiles branch on what the parent provides at build time — e.g. `if command -v R` (spark installs SparkR/sparklyr, jupyter installs IRkernel), `if command -v julia`, or `if [[ -n "${CUDA_VERSION}" ]]` (pytorch CUDA vs CPU wheels, R CUDA config). Keep that in mind when editing a shared layer: it must still work on every parent it is stacked on.

The valid layer stacks are declared in the `chains` dict in `src/images_datascience/build_chain.py` (local builds) and, independently, as the job graph in `.github/workflows/main-workflow.yml` (CI). Adding a new image means updating both.

### Script conventions inside Dockerfiles

- Every layer does `COPY --chmod=0755 scripts/ /opt/`, so `/opt` accumulates scripts from all parent layers. Child layers call helpers defined in `base/scripts/` without shipping them: `/opt/fix-user-permissions.sh`, `/opt/clean.sh`, `/opt/apt-install.sh <packages>` (installs missing apt packages, refreshing package lists if needed), and the install scripts shared by several layers (`/opt/install-python.sh` for python-minimal and r-python-julia, `/opt/install-java.sh` for r-datascience and spark). A script needed by more than one layer belongs in `base/scripts/`, not copied into each layer.
- Pattern for each layer: `USER root` → one `RUN` chaining install scripts → `/opt/fix-user-permissions.sh` → `/opt/clean.sh [extra files]` → `USER 1000`. The permission fix only chowns files not already owned by the user, to avoid duplicating files in layers.
- Downloads in build scripts must fail loudly: use `wget -nv` (never `-q`, which also hides error messages) and `curl -fsSL` (`-f` fails on HTTP errors, `-S` prints them despite `-s`). Put version lookups (`VERSION=$(curl ...)`) on their own line, and use `set -o pipefail` when they are piped, so that a failed lookup stops the build instead of producing a broken URL.
- Runtime user is `onyxia` (UID 1000, group `users` GID 100) with passwordless sudo; workdir is `/home/onyxia/work`.
- Python is built from source into `/opt/python` (not the system Python); packages are installed with `uv pip install --system`. R comes from rocker scripts (`/rocker_scripts/...`), with `R_HOME=/usr/local/lib/R`.
- `base/scripts/onyxia-init.sh` is the container init script used by Onyxia at startup (region init script, Vault secrets injection, CA bundles via `PATH_TO_CA_BUNDLE`, `PIP_REPOSITORY`/`R_REPOSITORY` mirrors — see README).

### CI (`.github/workflows/`)

- `main-workflow.yml` runs weekly (Monday 01:00 UTC) and on manual dispatch. It defines one job per output image with `needs:` dependencies mirroring the layer graph, each calling the reusable `main-workflow-template.yml` with `image` (output name), `context` (layer directory), `base_image`, and language versions.
- The template runs `src/images_datascience/generate_matrix.py` to expand versions × GPU/CPU into a build matrix (written to `$GITHUB_OUTPUT`), then builds, runs `<context>/tests.yaml`, and pushes only from `main`. GPU variants are built but **not tested** in CI: they are too big for GitHub-hosted runners to load and test (disk space).
- Images are built for **amd64 only**: no multi-arch build, and install scripts only download amd64 binaries. Don't add arm64 branches.
- Tag scheme: `onyxia-<image>:py<ver>` / `r<ver>` / `r<ver>-py<ver>`, plus `-spark<ver>`, `-gpu`, and a dated duplicate `-YYYY.MM.DD`. Base is `onyxia-base:latest[-gpu]`.
- Two versions of Python and R are actively maintained for users (`*_version_1` = newer, `*_version_2` = older); neither is a fallback. `r-python-julia` images only use version 1; spark images are CPU-only (`build_gpu: false`).

### Version pinning

The version inputs in `main-workflow.yml` are the source of truth for Python/R/Spark versions. They are duplicated in the `ARG` defaults of the `python-minimal`, `r-python-julia`, `r-minimal` and `spark` Dockerfiles and in the `*_VERSION_*` variables of `build_chains.sh`. `renovate.json` has one regex manager per version slot (Python 1/2, R 1/2, Spark) covering all of these files, and groups each slot into a single PR; version 2 only gets patch bumps, so moving it to a new minor release (e.g. when version 1 moves on) is a manual change. When changing a version by hand, update every occurrence; when adding a new place that pins one of these versions, add its pattern to the matching manager. CUDA base image tags (`build_chain.py`, `main-workflow.yml`) are not managed and must be updated manually.

Tools downloaded at build time (kubectl, helm, AWS CLI, DuckDB CLI, quarto, opencode, Julia, code-server) are pinned in their install script, **not** in Dockerfiles (Dockerfiles only pin the versions the project manages: Python, R, Spark). Each script follows the same model, see `base/scripts/install-kubectl.sh`:
- a `# renovate: datasource=<datasource> depName=<name>` comment right above a `<TOOL>_VERSION="x.y.z"` line. One generic regex manager in `renovate.json` picks it up (in `scripts/*.sh` and in `.github/actions/*/action.yml`, where container-structure-test is pinned the same way), and all tool bumps land in a single weekly "Build tools" PR.
- the official release file is downloaded to a `mktemp -d` directory and verified before installing: against the upstream checksum file when there is one (kubectl, helm, quarto, Julia), against the SHA-256 GitHub records for the release asset (read from the GitHub API in the script, with `set -o pipefail`) when there is none (DuckDB, opencode, code-server), and with the PGP signature for the AWS CLI (the public key is embedded in `install-awscli.sh` and expires on 2027-07-01).
- amd64 only.
