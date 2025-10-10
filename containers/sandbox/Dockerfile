FROM ghcr.io/ca4022/csc1109-dind-minimal:latest AS lab6-environment

COPY --from=docker.io/apache/hadoop:3.4.1 /opt/hadoop/ /opt/hadoop/
COPY --from=docker.io/apache/hive:4.0.1 /opt/hive/ /opt/hive/
ENV HADOOP_RUNNER_IMAGE=docker.io/apache/hadoop-runner
ENV HADOOP_RUNNER_VERSION=jdk17-u2204
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop
ENV SPARK_IMAGE=docker.io/library/spark
ENV SPARK_VERSION=4.0.0-scala2.13-java17-python3-ubuntu
ENV HIVE_IMAGE=docker.io/apache/hive
ENV HIVE_VERSION=4.0.1
ENV HIVE_HOME=/opt/hive
ENV HIVE_USER_NAME=hive
ENV IS_RESUME=false

COPY deploy-stack.service /etc/systemd/system/deploy-stack.service
COPY ./lab/ /lab/
COPY ./stack/ /opt/stack/
WORKDIR /lab/

RUN chmod -R 777 /lab/ && \
    chmod +x /opt/stack/hive-init/init && \
    chmod +x /entrypoint.sh && \
    systemctl enable deploy-stack.service
