FROM ghcr.io/ca4022/csc1109-dind:latest AS lab1-environment

ENV HADOOP_RUNNER_IMAGE=ghcr.io/ca4022/hadoop
ENV HADOOP_RUNNER_VERSION=3.4.2-lean-jdk17
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop

ENV UV_PYTHON_PREFERENCE=only-system
ENV UV_LINK_MODE=copy
ENV UV_PYTHON=python3.12

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

COPY ./lab/ /lab/
RUN chown -R 1000 /lab/
