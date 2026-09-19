# Improvement plan

Audit of the repository done on 2026-09-19. Each item has an ID, the evidence found, the intended fix and an effort estimate (**S** < 1h, **M** ≈ half a day, **L** multi-day). Tick the box and add the PR number when an item is done.

## Context at audit time

- No Docker was available during the audit: findings come from reading the code, shellcheck, the Docker Hub API (published layer sizes) and the GitHub API (CI history). Image contents were not inspected directly.
- **CI health:** 5 of the last 8 weekly runs of `main-workflow.yml` failed.
  - `r-datascience` failed every week from 2026-08-03 to 2026-08-31, which skipped rstudio, jupyter-r, r-python-julia and their IDE images for 4 weeks. This was fixed by the PostgreSQL APT repository commits.
  - 2026-09-14: `base` failed on `/opt/install-mc.sh`, already removed by commit 15dbaa6.
  - No PR runs CI, and no one is notified of failures.
- **Published sizes (compressed, amd64):**

  | Image | Size |
  |---|---|
  | base | 0.95 GB (one 924 MB `RUN` layer) |
  | python-minimal | 1.24 GB |
  | python-datascience | 1.94 GB (702 MB geospatial + requirements layer) |
  | jupyter-python | 2.06 GB |
  | vscode-python | 2.44 GB |
  | rstudio | 2.5 GB |
  | jupyter-pyspark | 3.46 GB |
  | jupyter-python GPU | 7.18 GB |
  | jupyter-pytorch GPU | 9.5 GB |

- **shellcheck** (`uvx --from shellcheck-py shellcheck $(git ls-files '*.sh')`): 197 findings, 162 of them SC2086 (unquoted variables).

## P0 — Bugs and quick wins

- [x] **1. AWS CLI installer left in every image** — S (fixed: install from a `mktemp -d` directory, removed afterwards)
  - Evidence: `base/scripts/install-awscli.sh:18-20` downloads `awscliv2.zip` and unzips `./aws` into the current directory, which is `WORKDIR ${WORKSPACE_DIR}` = `/home/onyxia/work` (see `base/Dockerfile`). Neither is deleted, so both ship in base's 924 MB layer and in every image built on it.
  - Fix: work in a `mktemp -d` directory and remove it; drop the pointless `sudo` (the script already runs as root).
- [x] **2. Redirect bug and leftover pip caches** — S (fixed: GDAL installed with `uv pip install --system --no-cache "gdal[numpy]==..."` plus an `osgeo.gdal_array` import check; the build dependency pre-install was dropped because GDAL's pyproject.toml declares them for the isolated build. radian later removed altogether, see #21)
  - Evidence: `python-datascience/scripts/install-geospatial-python.sh:21` runs `uv pip install --system numpy>1.0.0 wheel setuptools>=67` unquoted. Bash reads `>1.0.0` and `>=67` as redirects, so the constraints are ignored and files `1.0.0` and `=67` are created in `/home/onyxia/work` (shellcheck SC2261).
  - Evidence: the next line, `pip install gdal[numpy]==...`, has no `--no-cache-dir`. Nor does `pip install radian` in `vscode/scripts/install-vscode-extensions.sh:75`. Both leave a pip cache in `~/.cache/pip`, because `HOME=/home/onyxia` during builds.
  - Fix: quote the requirement specifiers, add `--no-cache-dir` (or use `uv pip install --system --no-cache`), and quote `"gdal[numpy]==..."`.
- [x] **3. Spark entrypoint dumps the environment to pod logs** — S (fixed: `env` call removed)
  - Evidence: `spark/scripts/spark-entrypoint.sh:132` calls `env` before exec for driver/executor commands. This prints any credentials passed to executor pods (e.g. `AWS_*` via `spark.kubernetes.executorEnv`) into the pod logs.
  - Fix: remove the line.
- [x] **4. `${WORKSPACE_DIR}` not expanded in exec-form CMD** — S (fixed: jupyter drops `--notebook-dir` and starts in `WORKDIR`; vscode uses `CMD ["/bin/bash", "-c", "exec code-server ... \"${WORKSPACE_DIR}\""]`)
  - Evidence: `jupyter/Dockerfile:35` and `vscode/Dockerfile:29`. Exec form does no variable substitution, so a plain `docker run` passes the literal string `${WORKSPACE_DIR}`. jupyter_server resolves it to `/home/onyxia/work/${WORKSPACE_DIR}` and refuses to start ("No such directory").
  - Scope: **Onyxia is not affected.** The helm charts in InseeFrLab/helm-charts-interactive-services override `command`/`args` (`/bin/sh -c "<init script> jupyter lab ..."` without `--notebook-dir`, and `code-server ... /home/<user>/work`), so the image CMD is never used there. Jupyter opens in the image `WORKDIR` (`/home/onyxia/work`). Only standalone use of the images (plain `docker run`, other platforms) hits the bug.
  - Fix: use the literal path `/home/onyxia/work`, or shell form wrapped with `exec`.
- [ ] **5. Hardcoded py4j filename** — S
  - Evidence: `spark/Dockerfile:17` sets `PYTHONPATH` to `py4j-0.10.9.9-src.zip`. Renovate now bumps `SPARK_VERSION` automatically; when Spark ships a new py4j, `import pyspark` breaks and no test catches it.
  - Fix: in `install-spark-hadoop-hive.sh`, symlink `${SPARK_HOME}/python/lib/py4j-*-src.zip` to a fixed name (e.g. `py4j-src.zip`) and reference that name. Add an `import pyspark` test (see #7).
  - **Deferred, and widened to a full audit of the Spark/Hadoop/Hive install** (to do after the easier items). The goal is to simplify it a lot. Questions to answer, none verified yet:
    - Spark comes from a custom build (`spark-${SPARK_VERSION}-bin-hadoop-${HADOOP_VERSION}-hive-${HIVE_VERSION}-java-${JAVA_VERSION}.tgz`, built by InseeFrLab/Spark-hive and hosted on `minio.lab.sspcloud.fr`). Is that still needed, or would the official Apache distribution or `pip install pyspark` do?
    - A separate full Hadoop distribution is installed, and `SPARK_DIST_CLASSPATH=$(hadoop classpath)` is set in `spark-env.sh` and the entrypoint. Are Hadoop jars shipped twice, once in the Spark build and once in `HADOOP_HOME`?
    - A full Hive 2.3.10 distribution is installed. Spark built with `-Phive` already bundles the Hive 2.3 client for the metastore. What is the full distribution used for, beyond the `hive-authentication` and `hive-listener` jars and the postgres JDBC driver?
    - Several hand fixes are tied to exact jar names: remove guava 14, copy guava 27, swap jline, and remove `bundle-2.29.52.jar` "to fix multiple bindings". The last one is the AWS SDK bundle that `hadoop-aws` needs. Where does S3A get the SDK from, and will these fixes survive version bumps?
    - `HADOOP_VERSION`, `HIVE_VERSION`, the jline/guava and postgres JDBC versions are hardcoded in the script and not managed by Renovate.
    - SparkR is installed with `remotes::install_github('apache/spark@v${SPARK_VERSION}', subdir='R/pkg')`, and the R layer also runs `install_tidyverse.sh`.
    - `spark-entrypoint.sh` is a copy of the upstream Spark-on-Kubernetes entrypoint, including dead `PYSPARK_MAJOR_PYTHON_VERSION == 2` handling. Compare it with the current upstream version.

## P1 — Reliability and security

- [x] **6. No CI on pull requests** — M (done for linting only: `.github/workflows/lint.yml` runs ruff, shellcheck (warning level) and hadolint (`.hadolint.yaml`) on PRs. **Building images on PRs was rejected**: it was tried before and costs too much compute)
  - Evidence: `.github/workflows/main-workflow.yml` triggers only on `schedule` and `workflow_dispatch`. Renovate PRs (including the Python/R/Spark regex managers) and contributor PRs merge without being built.
  - Fix: a new PR workflow with two parts:
    - lint job: `uv run ruff check`, `ruff format --check`, shellcheck, hadolint, `renovate-config-validator`
    - build job: builds and tests only the layers whose directories changed (path filters), CPU only, one version, no push. Parent images come from Docker Hub.
- [x] **7. Container tests only check binary paths** — M (done except spark: each `tests.yaml` has a `# Functional tests` section derived from its Dockerfile, with `if command -v …` guards where the layer is stacked on several parents, plus a "Workspace is empty" check. The base, python-minimal, r-minimal and r-datascience tests were run once against the published images and pass, except the workspace check, which fails there because of #1/#2 until the next build. The other layers' tests have not been run. **Spark tests are still to write**, together with #5)
  - Evidence: every `*/tests.yaml` is a near-copy of `which helm/kubectl/duckdb/...` checks. Nothing verifies that packages import or services start.
  - Fix: add at least one functional `commandTests` entry per layer, for example:
    - python-datascience: `python -c "import geopandas, osgeo.gdal, polars, sklearn"`
    - python-pytorch: `python -c "import torch"`
    - spark: `python -c "import pyspark"` plus a local `SparkSession`; for R, `library(sparklyr)` and `library(SparkR)`
    - r-datascience: `Rscript -e "library(tidyverse); library(arrow); library(duckdb)"`
    - jupyter: `jupyter lab --version`
    - vscode: `code-server --list-extensions`
    - rstudio: `rstudio-server verify-installation`
    - base: `quarto check`, and `duckdb -c "LOAD httpfs"` run as the user
- [ ] **8. One failing variant blocks whole image families** — M (deferred until after #12)
  - Evidence: with `fail-fast: false`, a single failing matrix entry still fails the job, and every `needs:` child job is skipped for all versions.
  - Evidence: GPU variants skip the "Build and load" step (`if: !contains(..., 'gpu')` in `main-workflow-template.yml`), so they are first built in "Push to DockerHub". Their build errors show up as push failures, and GPU images are never tested.
  - Decisions:
    - **No failure notification**: the maintainers check the pipeline result every Monday morning.
    - **GPU images are not tested on purpose, for lack of disk**: they are too big for GitHub-hosted runners to load them into Docker and run the tests. Revisit once #12 has reduced image sizes; if GPU images become small enough, build and test them like the CPU ones.
  - Remaining fix to consider: separate GPU jobs from CPU jobs, so that a GPU failure doesn't block the CPU images built on top of it.
- [ ] **9. Unpinned, unverified downloads at build time** — M–L (do it tool by tool)
  - Evidence (all in the scripts named below):
    - ~~`install-helm.sh` pipes the `master` branch installer~~ Done: Helm 4 pinned as `HELM_VERSION` in `install-helm.sh`, installed from the official `get.helm.sh` archive with its SHA-256 checked, and bumped by a Renovate regex manager (`helm/helm` GitHub releases). Use it as the model for the other tools.
    - these fetch "latest": `install-kubectl.sh`, `install-duckdb-cli.sh`, `install-quarto.sh`, `install-julia.sh` (unauthenticated GitHub API; an empty version on rate limit isn't caught), `install-vscode.sh` (code-server `install.sh`), `install-opencode.sh` (`curl | bash`), `install-awscli.sh`
    - `spark/scripts/install-spark-hadoop-hive.sh` downloads Spark, Hadoop, Hive and jars (some from `minio.lab.sspcloud.fr`) without any checksum
    - Hadoop comes from `downloads.apache.org`, which only hosts current releases, so 3.4.2 will return 404 once it's superseded
  - Fix:
    - pin each tool as an `ARG` in its Dockerfile and verify its sha256
    - add a Renovate regex manager per tool, reusing the pattern in `renovate.json`
    - switch Hadoop and Hive downloads to `archive.apache.org`
    - also pin `HADOOP_VERSION`, `HIVE_VERSION` and the postgres JDBC version
- [ ] **10. `base/scripts/onyxia-init.sh` hardening** — M
  - Line 22: `curl --insecure $REGION_INIT_SCRIPT | bash` runs a script fetched without TLS verification at every startup. Use `--cacert "$PATH_TO_CA_BUNDLE"` when set, and make `--insecure` opt-in via a dedicated env var. This requires coordination with the Onyxia helm charts.
  - Lines 50-64: Vault values are pasted into `sudo sh -c "printf ... \"$value\""`, so a value containing `"`, `$` or a backtick gets corrupted or evaluated. This isn't privilege escalation, since that branch requires sudo anyway, but it breaks real secrets. Keys are also unquoted in the `jq` filter. Fix: `printf '%s=%q\n' "$key" "$value" | sudo tee -a /etc/environment`, and `jq --arg k "$key" '.data.data[$k]'`.
  - Lines 90-103: `GIT_PERSONAL_ACCESS_TOKEN` is put in the clone URL, so it's stored in plain text in `.git/config` and shown by `git remote -v`. Use a credential helper instead (e.g. `git credential approve`, or `git -c credential.helper=...` for the clone).
  - Lines 189-197: the DuckDB `CREATE SECRET` statement is built by string concatenation, so it breaks on quotes. Escape single quotes.
- [ ] **11. CI supply chain** — S (M with scanning)
  - Evidence: no `permissions:` block in either workflow; actions pinned to mutable tags (`@v7`, ...); `.github/actions/container-structure-test` downloads `latest` without a checksum, in jobs that hold the Docker Hub credentials.
  - Fix:
    - add `permissions: contents: read`
    - add `helpers:pinGitHubActionDigests` to `renovate.json` `extends`
    - pin the container-structure-test version and verify its checksum
  - Optional: Trivy scan, plus `sbom: true` / `provenance: true` in `docker/build-push-action`.

## P2 — Performance

- [ ] **12. Image size** — M
  - Evidence: sizes in the context section above.
  - Fix:
    - do #1 first
    - run `dive` on base and python-datascience to measure. Suspected big items: TinyTeX (`install-quarto.sh`) and `build-essential` in base, and the GDAL stack from the `ubuntugis-unstable` PPA in python-datascience.
    - consider moving TinyTeX and quarto to the IDE layers
    - add a CI step that reports layer sizes so regressions show up
- [ ] **13. Python compiled from source with PGO+LTO** — M
  - Evidence: `python-minimal/scripts/install-python.sh` and its duplicate `r-python-julia/scripts/install-python.sh` compile CPython with `--enable-optimizations --with-lto`. This sits on the critical path of every Python chain, × 2 versions × CPU/GPU.
  - Fix: install prebuilt python-build-standalone binaries (also PGO+LTO-optimized) with `uv python install` into `/opt/python`. The tests expect `/opt/python/bin/python` and `/opt/python/bin/pip`; `python` and `pip` symlinks may be needed. Check that C-extension builds (e.g. GDAL's Python bindings in #2) still work.
- [ ] **14. Container startup work** — S
  - Evidence: `onyxia-init.sh:221-226` runs `chown -R` over every directory in the workspace at each start, which is slow on volumes with virtualenvs or data. Lines 205-209 print every installed R package at each start.
  - Fix: `find "$f" ! -user "$USERNAME" -exec chown ...`, or limit to the cloned repo; drop the package listing or make it opt-in.
- [ ] **15. Useless CI steps** — S
  - Evidence: `docker/setup-qemu-action` runs, but no multi-arch build happens. `.github/actions/cache-common-images` pulls `golang` and `dockereng/export-build` in every job and warns "Failed to restore".
  - Fix: remove both.

## P3 — Code quality and maintainability

- [ ] **16. Duplicated scripts** — S–M
  - Evidence:
    - the `apt_install` function is copy-pasted in 6 scripts
    - `install-python.sh` exists in both python-minimal and r-python-julia (identical except for the final newline)
    - `install-java.sh` exists in both r-datascience and spark (identical)
  - Fix: because every layer copies `scripts/` to `/opt`, shared helpers can live in `base/scripts/` (e.g. `/opt/apt-install.sh`) and be called from child layers.
- [ ] **17. Two diverged definitions of the image graph** — M–L
  - Evidence: `chains` in `src/images_datascience/build_chain.py` versus the jobs in `main-workflow.yml`:
    - local chain `python-pyspark` is `pyspark` in CI
    - `jupyter-python-minimal` exists only locally, `vscode-pyspark` only in CI
    - the CUDA base image is `12.8.1` locally and `12.6.3` in CI
  - Fix: a single `images.yaml` (layers, parents, versions, GPU flag) that drives both the CI matrix and local builds. Alternatively, generate `main-workflow.yml` from it and check in CI that it's up to date.
- [ ] **18. Shell hygiene** — S (CI) + M (fixes)
  - Evidence: 197 shellcheck findings; no `pipefail` anywhere, so e.g. an empty Julia version slips through.
  - Progress: shellcheck now runs in CI at `--severity=warning`. The 1 error and 22 warnings were fixed (`onyxia-init.sh`: `$*` in the final echo, split `export`s, DuckDB SQL quoting; `spark-entrypoint.sh`: split `export`, documented `SC2206` ignore for intentional word splitting). About 180 info/style findings remain, mostly SC2086; raise the threshold once they are fixed.
  - Fix: add shellcheck to the lint job (#6), use `set -euo pipefail` in build scripts, and fix the findings incrementally. Be careful with `onyxia-init.sh`: it deliberately doesn't use `set -e`, so it tolerates failures at startup.
- [ ] **19. Half-built arm64 support** — S (decision)
  - Evidence: some scripts branch on `uname -m` (awscli, kubectl, duckdb), but `JAVA_HOME` (`*-amd64`), `install-quarto.sh`, `install-julia.sh` and `tests.yaml` are amd64-only, and CI builds amd64 only.
  - Fix: pick one. Either drop the arm64 branches, or commit to multi-arch builds.
- [ ] **20. Python tooling** — S
  - Evidence:
    - ~~`pyproject.toml` declares `ruff` as a runtime dependency instead of a dev group~~ Done: ruff, shellcheck-py and hadolint-py are in the `dev` dependency group
    - the `images-datascience` entry point (`__init__.py`) only prints a greeting
    - `generate_matrix.py` relies on globals (`DH_ORGA`, `args`, `TODAY_DATE`) defined under `__main__`
    - the tag scheme users depend on has no unit tests
  - Fix: move ruff to `[dependency-groups] dev`; pass config explicitly to functions; add pytest tests for the matrix/tag generation, run in the lint job.
- [ ] **21. Small items** — S each
  - The `ppa:ubuntugis/ubuntugis-unstable` PPA is used in published images (`install-geospatial-python.sh:14`).
  - Both `RPostgres` and the legacy `RPostgreSQL` are installed (`r-datascience/Dockerfile`).
  - Hive 2.3.10 is on an end-of-life line; the postgres JDBC is 42.7.3.
  - ~~radian (R console used by the vscode R setup) is no longer maintained.~~ Done: radian removed; `r.rterm.linux` left unset so vscode-R uses R from `PATH`, and the radian-only `r.bracketedPaste` setting removed.
  - The vscode layer's `remotes::install_github('ManuelHentschel/vscDebugger')` has no GitHub token, so it can hit rate limits. The spark layer already passes the `github_token` build secret; do the same here.
  - `import tkinter` fails in python-minimal (`libtk8.6.so` missing): `install-python.sh` purges its build dependencies with `apt-get purge --auto-remove`, which also removes the Tk runtime library. Harmless on a headless server; either keep `libtk8.6` installed or accept it.
  - README is outdated: it links `scripts/onyxia-init.sh` (now `base/scripts/`) and says 02:00 while the cron is `0 1 * * 1` (01:00 UTC).

## Suggested order

1. **Bundle A: one quick-win PR.** #1, #2, #3, #4, #11, #14, #15.
   #5 was moved out of this bundle and widened into a Spark stack audit, to do after the easier items.
2. **Bundle B: PR CI and functional tests.** #6, #7, and the lint part of #18. This is what makes the Renovate automation safe.
3. **Bundle C: failure isolation.** #8, after #12 (image size) since it may change the GPU testing choice.
4. **Bundle D: pinning with checksums, tool by tool.** #9.
5. **Bundle E: init-script hardening.** #10, coordinated with the helm charts.
6. **Then:** performance (#13, #12) and refactoring (#16, #17, #19, #20, #21).
