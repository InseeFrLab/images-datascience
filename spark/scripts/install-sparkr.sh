#!/bin/bash
set -e

SPARK_URL="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}"
SPARKR_ARCHIVE="SparkR_${SPARK_VERSION}.tar.gz"

TMP_DIR=$(mktemp -d)

# SparkR is released as a source package alongside the Spark distribution
curl -fsSL "${SPARK_URL}/${SPARKR_ARCHIVE}" -o "${TMP_DIR}/${SPARKR_ARCHIVE}"
curl -fsSL "${SPARK_URL}/${SPARKR_ARCHIVE}.sha512" -o "${TMP_DIR}/${SPARKR_ARCHIVE}.sha512"
(cd "${TMP_DIR}" && sha512sum --check --strict "${SPARKR_ARCHIVE}.sha512")
R CMD INSTALL "${TMP_DIR}/${SPARKR_ARCHIVE}"
rm -rf "${TMP_DIR}"

# Other R interfaces to Spark
install2.r --ncpus -1 --error \
    arrow \
    sparklyr
