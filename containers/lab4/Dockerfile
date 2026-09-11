FROM ghcr.io/ca4022/csc1109-dind:latest AS lab4-environment

COPY --from=docker.io/library/storm:2.8.9-jre17 /apache-storm/ /apache-storm/

ENV STORM_IMAGE=ghcr.io/ca4022/storm
ENV STORM_VERSION=2.8.9-jre17
ENV STORM_HOME=/opt/storm
ENV STORM_USER_NAME=storm
ENV ZOOKEEPER_IMAGE=ghcr.io/ca4022/zookeeper
ENV ZOOKEEPER_VERSION=3.9.5-jre-17

RUN python3 -m ensurepip && python3 -m pip install --upgrade pip

COPY ./lab/ /lab/
RUN chown -R 1000 /lab/
