#!/bin/bash

HADOOP_VERSION="3.3.4"
HIVE_VERSION="2.3.9"
HIVE_LISTENER_VERSION="0.0.3"

export SPARK_BUILD_S3_BUCKET="https://minio.lab.sspcloud.fr/projet-onyxia/build"
export SPARK_BUILD_NAME="spark-${SPARK_VERSION}-bin-hadoop-${HADOOP_VERSION}-hive-${HIVE_VERSION}"
export HADOOP_URL="https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}"
export HADOOP_AWS_URL="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws"
export HIVE_URL="https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}"
export HIVE_AUTHENTICATION_JAR="hive-authentication.jar"
export HIVE_LISTENER_JAR="hive-listener-${HIVE_LISTENER_VERSION}.jar"

# Spark for Kubernetes with Hadoop, Hive and Kubernetes support
# Built here : https://github.com/InseeFrLab/Spark-hive
mkdir -p $SPARK_HOME
wget -q ${SPARK_BUILD_S3_BUCKET}/spark-hive/${SPARK_BUILD_NAME}.tgz
tar xzf ${SPARK_BUILD_NAME}.tgz -C $SPARK_HOME --owner root --group root --no-same-owner --strip-components=1

# Hadoop
mkdir -p $HADOOP_HOME
wget -q ${HADOOP_URL}/hadoop-${HADOOP_VERSION}.tar.gz
tar xzf hadoop-${HADOOP_VERSION}.tar.gz -C ${HADOOP_HOME} --owner root --group root --no-same-owner --strip-components=1
wget -q ${HADOOP_AWS_URL}/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar
mkdir -p ${HADOOP_HOME}/share/lib/common/lib
mv hadoop-aws-${HADOOP_VERSION}.jar ${HADOOP_HOME}/share/lib/common/lib

# Hive
mkdir -p $HIVE_HOME
wget -q ${HIVE_URL}/apache-hive-${HIVE_VERSION}-bin.tar.gz
tar xzf apache-hive-${HIVE_VERSION}-bin.tar.gz -C ${HIVE_HOME} --owner root --group root --no-same-owner --strip-components=1
wget -q ${SPARK_BUILD_S3_BUCKET}/hive-authentication/${HIVE_AUTHENTICATION_JAR}
mv ${HIVE_AUTHENTICATION_JAR} ${HIVE_HOME}/lib/
wget -q ${SPARK_BUILD_S3_BUCKET}/hive-listener/${HIVE_LISTENER_JAR}
mv ${HIVE_LISTENER_JAR} ${HIVE_HOME}/lib/hive-listener.jar

# Add postgreSQL support to Hive
wget -q https://jdbc.postgresql.org/download/postgresql-42.2.18.jar
mv postgresql-42.2.18.jar ${HIVE_HOME}/lib/postgresql-jdbc.jar

# Fix versions inconsistencies of some binaries between Hadoop & Hive distributions
rm ${HIVE_HOME}/lib/guava-14.0.1.jar
cp ${HADOOP_HOME}/share/hadoop/common/lib/guava-27.0-jre.jar ${HIVE_HOME}/lib/
wget -q https://repo1.maven.org/maven2/jline/jline/2.14.6/jline-2.14.6.jar
mv jline-2.14.6.jar ${HIVE_HOME}/lib/
rm ${HIVE_HOME}/lib/jline-2.12.jar
