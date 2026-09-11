FROM ghcr.io/ca4022/csc1109-dind:latest AS lab3-environment

ENV HADOOP_RUNNER_IMAGE=ghcr.io/ca4022/hadoop
ENV HADOOP_RUNNER_VERSION=3.5.0
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop
ENV PIG_HOME=/opt/pig/

RUN wget https://downloads.apache.org/pig/pig-0.18.0/pig-0.18.0.tar.gz && \
    tar -xzf pig-0.18.0.tar.gz && \
    rm pig-0.18.0.tar.gz && \
    mv pig-0.18.0 /opt/pig && \
    mkdir -p /opt/pig/lib/h3/ && \
    cp /opt/pig/lib/hadoop3-runtime/commons-collections-3.2.2.jar /opt/pig/lib/h3/

COPY ./lab/ /lab/
RUN chown -R 1000 /lab/ && \
    useradd -m $HADOOP_USER_NAME && \
    mkdir -p $HADOOP_HOME && \
    chown -R $HADOOP_USER_NAME $HADOOP_HOME
