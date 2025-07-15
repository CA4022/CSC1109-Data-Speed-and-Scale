FROM ghcr.io/amileo/csc1109-base:latest AS lab1-environment

COPY --from=docker.io/apache/hadoop:3.4.1 /opt/hadoop/ /opt/hadoop/
COPY --from=docker.io/apache/hive:4.0.1 /opt/hive/ /opt/hive/
ENV HADOOP_RUNNER_IMAGE=docker.io/apache/hadoop-runner
ENV HADOOP_RUNNER_VERSION=jdk17-u2204
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop
ENV HIVE_IMAGE=docker.io/apache/hive
ENV HIVE_VERSION=4.0.1
ENV HIVE_HOME=/opt/hive
ENV HIVE_USER_NAME=hive
ENV IS_RESUME=false

COPY ./lab/ /lab/
RUN chown -R 1000 /lab/ && \
    mvn dependency:copy \
        -Dartifact=org.postgresql:postgresql:42.2.24:jar \
        -DoutputDirectory=/opt/hive/lib/ \
        -Dmdep.stripVersion=true
