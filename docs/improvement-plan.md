# Improvement plan

Remaining work from the repository audit of 2026-09-19; fixed items have been removed. Item numbers are kept from the original audit. Effort: **S** < 1h, **M** ≈ half a day, **L** multi-day.

## Open items

### 5. Spark/Hadoop/Hive install — L

Audit and simplify the whole Spark layer (`spark/`). None of the questions below have been checked yet.

- **py4j filename:** `spark/Dockerfile` sets `PYTHONPATH` to `py4j-0.10.9.9-src.zip`. Renovate bumps `SPARK_VERSION` automatically, so when Spark ships a new py4j, `import pyspark` breaks. Quick fix: symlink `${SPARK_HOME}/python/lib/py4j-*-src.zip` to a fixed name in `install-spark-hadoop-hive.sh` and reference that name.
- **Spark tests:** `spark/tests.yaml` still only checks binary paths. Add functional tests like the other layers: `import pyspark` and a local `SparkSession` when Python is present, `library(sparklyr)` and `library(SparkR)` when R is present.
- **Custom Spark build:** Spark comes from `spark-${SPARK_VERSION}-bin-hadoop-${HADOOP_VERSION}-hive-${HIVE_VERSION}-java-${JAVA_VERSION}.tgz`, built by InseeFrLab/Spark-hive and hosted on `minio.lab.sspcloud.fr`. Is it still needed, or would the official Apache distribution or `pip install pyspark` do?
- **Hadoop shipped twice?** A full Hadoop distribution is installed, and `SPARK_DIST_CLASSPATH=$(hadoop classpath)` is set in `spark-env.sh` and the entrypoint.
- **Full Hive 2.3.10 distribution:** Spark built with `-Phive` already bundles the Hive 2.3 client. What is the full distribution used for, beyond the `hive-authentication` and `hive-listener` jars and the postgres JDBC driver? Hive 2.3 is also an end-of-life line, and the postgres JDBC driver is 42.7.3.
- **Hand fixes tied to exact jar names:** remove guava 14, copy guava 27, swap jline, and remove `bundle-2.29.52.jar` "to fix multiple bindings". That last jar is the AWS SDK bundle `hadoop-aws` needs: where does S3A get the SDK from, and will these fixes survive version bumps?
- **Downloads:**
  - `HADOOP_VERSION`, `HIVE_VERSION` and the jline/guava/JDBC versions are hardcoded and not tracked by Renovate.
  - Nothing is checksum-verified, unlike the other install scripts.
  - Hadoop comes from `downloads.apache.org`, which only hosts current releases, so 3.4.2 will return 404 once superseded. Use `archive.apache.org`.
- **SparkR:** installed with `remotes::install_github('apache/spark@v${SPARK_VERSION}', subdir='R/pkg')`, and the R variant also runs rocker's `install_tidyverse.sh`.
- **`spark-entrypoint.sh`:** a copy of the upstream Spark-on-Kubernetes entrypoint, including dead `PYSPARK_MAJOR_PYTHON_VERSION == 2` handling. Compare it with the current upstream version.

### 12. Image size — M

Published sizes on 2026-09-19 (compressed, amd64):

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

- Re-measure after the next build: the AWS CLI installer leftovers (about 70 MB zip + unzipped folder) are now removed from base.
- Run `dive` on base and python-datascience. Suspected big items: TinyTeX (`install-quarto.sh`) and `build-essential` in base, and the GDAL stack from the ubuntugis PPA in python-datascience.
- Consider moving TinyTeX and quarto to the IDE layers.
- Add a CI step that reports layer sizes, so regressions show up.
- **GPU testing:** GPU images are not tested in CI because they are too big for GitHub-hosted runners to load and test. Once sizes are reduced, check whether they fit, and test them like the CPU ones if so.

### 13. Python compiled from source — M

`base/scripts/install-python.sh` compiles CPython with `--enable-optimizations --with-lto`. That sits on the critical path of every Python chain (python-minimal and r-python-julia), × 2 versions × CPU/GPU.

- Fix: install prebuilt python-build-standalone binaries (also PGO+LTO-optimized) with `uv python install` into `/opt/python`.
- The tests expect `/opt/python/bin/python` and `/opt/python/bin/pip`, so `python` and `pip` symlinks may be needed.
- Check that C-extension builds still work, e.g. GDAL's Python bindings in python-datascience.

### 14. Container startup work — S

At every start, the end of `base/scripts/onyxia-init.sh` runs `chown -R` over every folder in `$ROOT_PROJECT_DIRECTORY`. That's slow on volumes with virtualenvs or data, and useless when the script runs as `onyxia` (Jupyter, VS Code), since a normal user can't change file owners.

- Suggested fix: only when running as root (RStudio), and only for files that need it:
  ```bash
  if [[ $(id -u) = 0 ]]; then
      find "$ROOT_PROJECT_DIRECTORY" -mindepth 1 -path "$ROOT_PROJECT_DIRECTORY/lost+found" -prune \
          -o \! -user "$USERNAME" -exec chown --no-dereference "$USERNAME:$GROUPNAME" {} +
  fi
  ```
- Complementary, in the helm charts: `fsGroup` with `fsGroupChangePolicy: OnRootMismatch`.

### 17. Two definitions of the image graph — M

The image stacks are still declared twice: `chains` in `utils/build_chain.py` (local builds) and the jobs in `.github/workflows/main-workflow.yml` (CI). They currently match, and versions and the CUDA image already come from a single `versions.env`, but adding an image means editing both.

Fix: a single `images.yaml` (layers, parents, languages, GPU flag) that drives both the CI matrix and local builds. Alternatively, generate `main-workflow.yml` from it and check in CI that it's up to date.

### 21. Small items — S

- **`RDebugger.r-debugger` VS Code extension:** still installed by `vscode/scripts/install-vscode-extensions.sh`, but its R backend `vscDebugger` was removed, so R debugging doesn't work (the extension only offers to install the package at first use). Remove it from `r_extensions`, and from the vscode tests if they list it.

## Optional ideas

- CI: Trivy vulnerability scan, and `sbom: true` / `provenance: true` in `docker/build-push-action`.
- Shell: the remaining ~148 shellcheck info/style findings, mostly unquoted variables that never hold spaces (72 of them in `onyxia-init.sh`). Once fixed, raise the CI threshold to `info`.
- Python: unit tests for the tag scheme in `utils/generate_matrix.py`, run in `check-code-quality.yml`.
- Security: `curl --insecure $REGION_INIT_SCRIPT | bash` in `onyxia-init.sh` is tracked in a separate GitHub issue.

## Decisions (don't reopen)

- **Images are not built on PRs:** it was tried and costs too much compute. PRs only get linting, which is skipped for Renovate PRs.
- **No notification on build failure:** the pipeline result is checked every Monday morning.
- **A failed layer fails all its children:** the CI job structure is kept, with no GPU/CPU split.
- **GitHub actions stay pinned to version tags,** not digests.
- **Tool versions are pinned in install scripts,** not in Dockerfiles, which only pin Python, R and Spark.
- **amd64 only.**
- **The Git token stays in the clone URL:** containers are isolated and short-lived, and moving it to a credential helper would still leave it readable in plain text.
- **DuckDB secret values are not SQL-escaped:** AWS/MinIO credentials can't contain quotes.
- **`import tkinter` is broken in the images:** irrelevant for headless images.
