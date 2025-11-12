FROM ghcr.io/ca4022/csc1109-dind:latest AS lab5-environment

COPY --from=docker.io/library/spark:4.0.0-scala2.13-java17-python3-ubuntu /opt/ /opt/
COPY --from=docker.io/apache/hadoop:3.4.1 /opt/hadoop/ /opt/hadoop/
ENV HADOOP_RUNNER_IMAGE=docker.io/apache/hadoop-runner
ENV HADOOP_RUNNER_VERSION=jdk17-u2204
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop
ENV SPARK_IMAGE=docker.io/library/spark
ENV SPARK_VERSION=4.0.0-scala2.13-java17-python3-ubuntu
ENV SPARK_HOME=/opt/spark/
ENV SPARK_LOCAL_IP="127.0.0.1"

COPY ./lab/ /lab/
RUN chmod -R 777 /lab/
