FROM ghcr.io/ca4022/csc1109-dind-minimal:latest AS lab6-environment

COPY --from=docker.io/apache/hadoop:3.4.1 /opt/hadoop/ /opt/hadoop/
ENV HADOOP_RUNNER_IMAGE=docker.io/apache/hadoop-runner
ENV HADOOP_RUNNER_VERSION=jdk17-u2204
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop
ENV SPARK_IMAGE=docker.io/library/spark
ENV SPARK_VERSION=4.0.0-scala2.13-java17-python3-ubuntu

COPY ./lab/ /lab/
RUN chmod -R 777 /lab/
WORKDIR /lab/

COPY /entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT /entrypoint.sh
