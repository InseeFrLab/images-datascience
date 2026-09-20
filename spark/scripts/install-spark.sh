#!/bin/bash
set -e
set -o pipefail

SPARK_URL="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}"
SPARK_ARCHIVE="spark-${SPARK_VERSION}-bin-hadoop3.tgz"
MAVEN_URL="https://repo1.maven.org/maven2"

TMP_DIR=$(mktemp -d)

# Download the official Spark distribution and verify its checksum
curl -fsSL "${SPARK_URL}/${SPARK_ARCHIVE}" -o "${TMP_DIR}/${SPARK_ARCHIVE}"
curl -fsSL "${SPARK_URL}/${SPARK_ARCHIVE}.sha512" -o "${TMP_DIR}/${SPARK_ARCHIVE}.sha512"
(cd "${TMP_DIR}" && sha512sum --check --strict "${SPARK_ARCHIVE}.sha512")

mkdir -p "${SPARK_HOME}"
tar xzf "${TMP_DIR}/${SPARK_ARCHIVE}" -C "${SPARK_HOME}" --owner root --group root --no-same-owner --strip-components=1

# The S3A connector is the one thing the distribution does not ship (it is built without
# -Phadoop-cloud). Its versions are read from the distribution itself, so they cannot drift from
# the Hadoop client it embeds.
HADOOP_VERSION=$(basename "${SPARK_HOME}"/jars/hadoop-client-api-*.jar .jar | sed "s|^hadoop-client-api-||")
HADOOP_POM="${MAVEN_URL}/org/apache/hadoop/hadoop-project/${HADOOP_VERSION}/hadoop-project-${HADOOP_VERSION}.pom"
curl -fsSL "${HADOOP_POM}" -o "${TMP_DIR}/hadoop-project.pom"

# Read a <property> value from the Hadoop POM, failing the build if it is not there
read_pom_property() {
    local value
    value=$(sed -n "s|.*<$1>\([^<]*\)</$1>.*|\1|p" "${TMP_DIR}/hadoop-project.pom")
    if [[ -z "${value}" ]]; then
        echo "Property $1 not found in ${HADOOP_POM}" >&2
        exit 1
    fi
    echo "${value}"
}

# Download a jar from Maven Central into the Spark classpath and verify its checksum
install_maven_jar() {
    local jar="$2-$3.jar"
    local url="${MAVEN_URL}/$1/$2/$3/${jar}"
    curl -fsSL "${url}" -o "${TMP_DIR}/${jar}"
    SHA1=$(curl -fsSL "${url}.sha1")
    echo "${SHA1}  ${TMP_DIR}/${jar}" | sha1sum --check --strict
    mv "${TMP_DIR}/${jar}" "${SPARK_HOME}/jars/"
}

install_maven_jar org/apache/hadoop hadoop-aws "${HADOOP_VERSION}"
install_maven_jar software/amazon/awssdk bundle "$(read_pom_property "aws-java-sdk-v2.version")"
install_maven_jar software/amazon/s3/analyticsaccelerator analyticsaccelerator-s3 \
    "$(read_pom_property "amazon-s3-analyticsaccelerator-s3.version")"
install_maven_jar org/wildfly/openssl wildfly-openssl "$(read_pom_property "openssl-wildfly.version")"

# Version-independent path to py4j, referenced by PYTHONPATH
ln -s "$(basename "${SPARK_HOME}"/python/lib/py4j-*-src.zip)" "${SPARK_HOME}/python/lib/py4j-src.zip"

# The distribution ships the entrypoint Spark on Kubernetes expects from an image, used as is
test -x "${SPARK_HOME}/kubernetes/dockerfiles/spark/entrypoint.sh"
ln -s "${SPARK_HOME}/kubernetes/dockerfiles/spark/entrypoint.sh" /opt/spark-entrypoint.sh

rm -rf "${TMP_DIR}"
