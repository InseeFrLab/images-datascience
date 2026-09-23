ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ENV JAVA_VERSION="21"
ENV JAVA_HOME="/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64"

ARG SPARK_VERSION="4.2.0"
ENV SPARK_VERSION=${SPARK_VERSION}

ENV SPARK_HOME="/opt/spark"
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-src.zip"
ENV SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M"

ENV PATH="${SPARK_HOME}/bin:${JAVA_HOME}/bin:${PATH}"

USER root

COPY --chmod=0755 scripts/ /opt/

RUN /opt/install-java.sh && \
    # Install Spark and the S3A connector
    /opt/install-spark.sh && \
    # Fix user permissions
    /opt/fix-user-permissions.sh && \
    # Clean
    /opt/clean.sh

USER 1000

ENTRYPOINT [ "/opt/spark-entrypoint.sh" ]
