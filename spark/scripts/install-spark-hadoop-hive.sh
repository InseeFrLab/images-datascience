#!/bin/bash
set -e

HADOOP_VERSION="3.4.2"
HIVE_VERSION="2.3.10"
HIVE_LISTENER_VERSION="0.0.3"

SPARK_BUILD_S3_BUCKET="https://minio.lab.sspcloud.fr/projet-onyxia/build"
SPARK_BUILD_NAME="spark-${SPARK_VERSION}-bin-hadoop-${HADOOP_VERSION}-hive-${HIVE_VERSION}-java-${JAVA_VERSION}"
HADOOP_URL="https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}"
HADOOP_AWS_URL="https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws"
HIVE_URL="https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}"
HIVE_AUTHENTICATION_JAR="hive-authentication.jar"
HIVE_LISTENER_JAR="hive-listener-${HIVE_LISTENER_VERSION}.jar"

# Spark for Kubernetes with Hadoop, Hive and Kubernetes support
# Built here : https://github.com/InseeFrLab/Spark-hive
mkdir -p $SPARK_HOME
wget -q ${SPARK_BUILD_S3_BUCKET}/spark-hive/${SPARK_BUILD_NAME}.tgz
tar xzf ${SPARK_BUILD_NAME}.tgz -C $SPARK_HOME --owner root --group root --no-same-owner --strip-components=1
rm ${SPARK_BUILD_NAME}.tgz

# Hadoop
mkdir -p $HADOOP_HOME
wget -q ${HADOOP_URL}/hadoop-${HADOOP_VERSION}.tar.gz
tar xzf hadoop-${HADOOP_VERSION}.tar.gz -C ${HADOOP_HOME} --owner root --group root --no-same-owner --strip-components=1
rm hadoop-${HADOOP_VERSION}.tar.gz
wget -q ${HADOOP_AWS_URL}/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar
mkdir -p ${HADOOP_HOME}/share/lib/common/lib
mv hadoop-aws-${HADOOP_VERSION}.jar ${HADOOP_HOME}/share/lib/common/lib

# Hive
mkdir -p $HIVE_HOME
wget -q ${HIVE_URL}/apache-hive-${HIVE_VERSION}-bin.tar.gz
tar xzf apache-hive-${HIVE_VERSION}-bin.tar.gz -C ${HIVE_HOME} --owner root --group root --no-same-owner --strip-components=1
rm apache-hive-${HIVE_VERSION}-bin.tar.gz
wget -q ${SPARK_BUILD_S3_BUCKET}/hive-authentication/${HIVE_AUTHENTICATION_JAR}
mv ${HIVE_AUTHENTICATION_JAR} ${HIVE_HOME}/lib/
wget -q ${SPARK_BUILD_S3_BUCKET}/hive-listener/${HIVE_LISTENER_JAR}
mv ${HIVE_LISTENER_JAR} ${HIVE_HOME}/lib/hive-listener.jar

# Add postgreSQL support to Hive
wget -q https://jdbc.postgresql.org/download/postgresql-42.7.3.jar
mv postgresql-42.7.3.jar ${HIVE_HOME}/lib/postgresql-jdbc.jar

# Fix versions inconsistencies of some binaries between Hadoop & Hive distributions
rm ${HIVE_HOME}/lib/guava-14.0.1.jar
cp ${HADOOP_HOME}/share/hadoop/common/lib/guava-27.0-jre.jar ${HIVE_HOME}/lib/
wget -q https://repo1.maven.org/maven2/jline/jline/2.14.6/jline-2.14.6.jar
mv jline-2.14.6.jar ${HIVE_HOME}/lib/
rm ${HIVE_HOME}/lib/jline-2.12.jar

# Fix multiple bindings
rm ${HADOOP_HOME}/share/hadoop/tools/lib/bundle-2.24.6.jar

# Change log verbosity of Hadoop
sed -i -e "s/hadoop.root.logger=INFO,console/hadoop.root.logger=WARN,console/g" ${HADOOP_HOME}/etc/hadoop/log4j.properties
