#!/bin/bash

wget ${HADOOP_URL}/hadoop-${HADOOP_VERSION}.tar.gz
tar xzf hadoop-${HADOOP_VERSION}.tar.gz -C ${HADOOP_HOME} --owner root --group root --no-same-owner --strip-components=1
wget ${HADOOP_AWS_URL}/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar
mkdir -p ${HADOOP_HOME}/share/lib/common/lib
mv hadoop-aws-${HADOOP_VERSION}.jar ${HADOOP_HOME}/share/lib/common/lib

wget ${SPARK_BUILD_S3_BUCKET}/spark-hive/${SPARK_BUILD_NAME}.tgz
tar xzf ${SPARK_BUILD_NAME}.tgz -C $SPARK_HOME --owner root --group root --no-same-owner --strip-components=1

wget ${HIVE_URL}/apache-hive-${HIVE_VERSION}-bin.tar.gz
tar xzf apache-hive-${HIVE_VERSION}-bin.tar.gz -C ${HIVE_HOME} --owner root --group root --no-same-owner --strip-components=1

wget https://jdbc.postgresql.org/download/postgresql-42.2.18.jar
mv postgresql-42.2.18.jar ${HIVE_HOME}/lib/postgresql-jdbc.jar

rm ${HIVE_HOME}/lib/guava-14.0.1.jar
cp ${HADOOP_HOME}/share/hadoop/common/lib/guava-27.0-jre.jar ${HIVE_HOME}/lib/

wget https://repo1.maven.org/maven2/jline/jline/2.14.6/jline-2.14.6.jar
mv jline-2.14.6.jar ${HIVE_HOME}/lib/
rm ${HIVE_HOME}/lib/jline-2.12.jar

wget ${SPARK_BUILD_S3_BUCKET}/hive-authentication/${HIVE_AUTHENTICATION_JAR}
mv ${HIVE_AUTHENTICATION_JAR} ${HIVE_HOME}/lib/

wget ${SPARK_BUILD_S3_BUCKET}/hive-listener/${HIVE_LISTENER_SRC_JAR}
mv ${HIVE_LISTENER_SRC_JAR} ${HIVE_HOME}/lib/${HIVE_LISTENER_DEST_JAR}
