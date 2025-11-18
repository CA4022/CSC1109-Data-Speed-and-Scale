FROM ghcr.io/ca4022/csc1109-dind:latest AS lab3-environment

ENV HADOOP_RUNNER_IMAGE=ghcr.io/ca4022/hadoop
ENV HADOOP_RUNNER_VERSION=3.4.2-lean
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop
ENV PIG_HOME=/opt/pig/

RUN wget https://downloads.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz && \
    tar -xzf pig-0.17.0.tar.gz && \
    rm pig-0.17.0.tar.gz && \
    mv pig-0.17.0 /opt/pig

COPY ./lab/ /lab/
RUN chown -R 1000 /lab/ && \
    useradd -m $HADOOP_USER_NAME && \
    chown -R $HADOOP_USER_NAME $HADOOP_HOME
