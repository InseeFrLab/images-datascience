ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

ARG BASE_IMAGE

ARG SPARK_VERSION="3.3.1"
ENV SPARK_VERSION=${SPARK_VERSION}
ENV HADOOP_VERSION="3.3.4"
ENV HIVE_VERSION="2.3.9"
ENV HIVE_LISTENER_VERSION="0.0.3"

ENV HADOOP_HOME="/opt/hadoop"
ENV SPARK_HOME="/opt/spark"
ENV HIVE_HOME="/opt/hive"
ENV PYTHONPATH="$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.5-src.zip"
ENV SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M"
ENV JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
ENV HADOOP_OPTIONAL_TOOLS="hadoop-aws"

ENV PATH="${JAVA_HOME}/bin:${SPARK_HOME}/bin:${HADOOP_HOME}/bin:${PATH}"

USER root

RUN --mount=type=secret,id=github_token \
    apt-get update  && \
    # Install JDK
    apt-get install -y --no-install-recommends \
        ca-certificates-java \
        openjdk-11-jre-headless && \
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
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${HADOOP_HOME} ${SPARK_HOME} ${HIVE_HOME} && \
    # Change log verbosity of Hadoop
    sed -i -e "s/hadoop.root.logger=INFO,console/hadoop.root.logger=WARN,console/g" /opt/hadoop/etc/hadoop/log4j.properties && \
    # Clean
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*

USER 1000

ENTRYPOINT [ "/opt/spark-entrypoint.sh" ]
