FROM ghcr.io/ca4022/csc1109-dind:latest AS lab2-environment

COPY --from=docker.io/apache/hive:3.1.3 /opt/hive/ /opt/hive/
ENV HADOOP_RUNNER_IMAGE=ghcr.io/ca4022/hadoop
ENV HADOOP_RUNNER_VERSION=3.4.2-lean-jdk17
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop
ENV HIVE_IMAGE=docker.io/apache/hive
ENV HIVE_VERSION=3.1.3
ENV HIVE_HOME=/opt/hive
ENV HIVE_USER_NAME=hive
ENV IS_RESUME=false

COPY ./lab/ /lab/
RUN chown -R 1000 /lab/ && \
    mvn dependency:copy \
        -Dartifact=org.postgresql:postgresql:42.4.3:jar \
        -DoutputDirectory=/opt/hive/lib/ \
        -Dmdep.stripVersion=true
