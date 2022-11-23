ARG BASE_IMAGE=inseefrlab/onyxia-python-minimal
FROM $BASE_IMAGE

SHELL ["/bin/bash", "-c"]

ARG BASE_IMAGE

ENV SPARK_VERSION="3.3.0"
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

COPY get-binaries.sh /tmp/get-binaries.sh

RUN apt-get update && \
    # Install JDK
    apt-get install -y --no-install-recommends \
        ca-certificates-java \
        openjdk-11-jre-headless && \
    # Get Spark/Hadoop/Hive binaries
    mkdir -p $HADOOP_HOME $SPARK_HOME $HIVE_HOME && \
    ${SHELL} /tmp/get-binaries.sh && \
    # Install additional packages if base image is R
    if [[ "${BASE_IMAGE}" == *"r-minimal"* ]]; then \
        /rocker_scripts/install_tidyverse.sh && \
        R -e "install.packages('arrow')" && \
        R -e "remotes::install_github('apache/spark@v${SPARK_VERSION}', subdir='R/pkg')" && \
        R -e "install.packages('sparklyr')"; \
    fi && \
    # Fix permissions
    chown -R ${USERNAME}:${GROUPNAME} ${HOME} ${HADOOP_HOME} ${SPARK_HOME} ${HIVE_HOME} && \
    # Change log verbosity hadoop
    sed -i -e "s/hadoop.root.logger=INFO,console/hadoop.root.logger=WARN,console/g" /opt/hadoop/etc/hadoop/log4j.properties && \
    # Clean
    rm -rf /tmp/* && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=${USERNAME}:${GROUPNAME} --chmod=755 spark-env.sh $SPARK_HOME/conf
COPY --chown=${USERNAME}:${GROUPNAME} --chmod=755 entrypoint.sh /opt/entrypoint.sh

USER ${USERNAME}

ENTRYPOINT [ "/opt/entrypoint.sh" ]
