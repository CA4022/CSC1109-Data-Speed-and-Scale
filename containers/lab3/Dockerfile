FROM ghcr.io/amileo/csc1109-base:latest AS lab3-environment

COPY --from=docker.io/apache/hadoop:3.4.1 /opt/hadoop/ /opt/hadoop/
ENV HADOOP_RUNNER_IMAGE=docker.io/apache/hadoop-runner
ENV HADOOP_RUNNER_VERSION=jdk11-u2204
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop

COPY --from=ghcr.io/amileo/csc1109-lab3-client:latest /opt/pig/ /opt/pig/
ENV PATH=/opt/pig/bin/:$PATH
ENV PIG_HOME=/opt/pig/

COPY ./lab/ /lab/
RUN chown -R 1000 /lab/ && \
    useradd -m $HADOOP_USER_NAME && \
    chown -R $HADOOP_USER_NAME $HADOOP_HOME
