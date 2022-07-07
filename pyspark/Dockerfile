ARG BASE_IMAGE
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

USER root

ENV SPARK_VERSION=3.2.1
ENV HADOOP_VERSION=3.3.1
ENV HIVE_VERSION=2.3.9
ENV HIVE_LISTENER_VERSION=0.0.3
ENV HADOOP_URL="https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}"
ENV HADOOP_AWS_URL="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws"
ENV HIVE_URL="https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}"
ENV SPARK_BUILD_NAME="spark-${SPARK_VERSION}-bin-hadoop-${HADOOP_VERSION}-hive-${HIVE_VERSION}"
ENV SPARK_BUILD_S3_BUCKET="https://minio.lab.sspcloud.fr/projet-onyxia/build"
ENV HIVE_AUTHENTICATION_JAR="hive-authentication.jar"
ENV HIVE_LISTENER_SRC_JAR="hive-listener-${HIVE_LISTENER_VERSION}.jar"
ENV HIVE_LISTENER_DEST_JAR="hive-listener.jar"

ENV HADOOP_HOME="/opt/hadoop"
ENV SPARK_HOME="/opt/spark"
ENV HIVE_HOME="/opt/hive"

ENV PYTHONPATH="$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.3-src.zip"
ENV SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M"
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64""
ENV HADOOP_OPTIONAL_TOOLS="hadoop-aws"
ENV PATH="${JAVA_HOME}/bin:${SPARK_HOME}/bin:${HADOOP_HOME}/bin:${PATH}"

# Get Spark/Hadoop/Hive binaries
COPY get-binaries.sh /tmp/get-binaries.sh
RUN mkdir -p $HADOOP_HOME $SPARK_HOME $HIVE_HOME && \
    cd /tmp && \
    /bin/bash get-binaries.sh && \
    # Clean
    rm -rf /tmp/* && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HADOOP_HOME} ${SPARK_HOME} ${HIVE_HOME}

COPY --chown=${USERNAME}:${GROUPNAME} spark-env.sh $SPARK_HOME/conf
COPY --chown=${USERNAME}:${GROUPNAME} entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT [ "/opt/entrypoint.sh" ]
