ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

LABEL maintainer="InseeFrLab <innovation@insee.fr>"

ARG BASE_IMAGE

ENV JAVA_VERSION="17"
ENV JAVA_HOME="/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64"

ARG SPARK_VERSION="3.5.5"
ENV SPARK_VERSION=${SPARK_VERSION}
ENV HADOOP_HOME="/usr/local/lib/hadoop"
ENV SPARK_HOME="/usr/local/lib/spark"
ENV HIVE_HOME="/usr/local/lib/hive"
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.9.7-src.zip"
ENV SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M"
ENV HADOOP_OPTIONAL_TOOLS="hadoop-aws"

ENV PATH="${SPARK_HOME}/bin:${HADOOP_HOME}/bin:${JAVA_HOME}/bin:${PATH}"

USER root

COPY --chmod='+x' scripts/ /opt/

RUN --mount=type=secret,id=github_token \
    # Install JDK
    /opt/install-java.sh && \
    # Install Spark/Hadoop/Hive
    /opt/install-spark-hadoop-hive.sh && \
    # Put Spark config in the right place
    cp /opt/spark-env.sh $SPARK_HOME/conf && \
    # Install additional packages if R is installed
    if command -v R; then \
        /rocker_scripts/install_tidyverse.sh && \
        export GITHUB_PAT=`cat /run/secrets/github_token` && \
        R -e "install.packages(c('sparklyr', 'arrow'))" && \
        R -e "remotes::install_github('apache/spark@v${SPARK_VERSION}', subdir='R/pkg')"; \
    fi && \
    # Fix user permissions
    /opt/fix-user-permissions.sh && \
    # Clean
    /opt/clean.sh

USER 1000

ENTRYPOINT [ "/opt/spark-entrypoint.sh" ]
