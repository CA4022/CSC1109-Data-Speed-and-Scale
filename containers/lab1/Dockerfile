FROM ghcr.io/ca4022/csc1109-dind:latest AS lab1-environment

COPY --from=docker.io/apache/hadoop:3.4.1 /opt/hadoop/ /opt/hadoop/
ENV HADOOP_RUNNER_IMAGE=docker.io/apache/hadoop-runner
ENV HADOOP_RUNNER_VERSION=jdk17-u2204
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop

COPY ./lab/ /lab/
RUN chown -R 1000 /lab/ && \
    useradd -m $HADOOP_USER_NAME && \
    chown -R $HADOOP_USER_NAME $HADOOP_HOME

USER $HADOOP_USER_NAME
RUN uv sync
USER root
