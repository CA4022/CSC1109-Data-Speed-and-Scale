FROM ghcr.io/ca4022/csc1109-dind:latest AS lab4-environment

COPY --from=docker.io/library/storm:2.8.1-jre17 /apache-storm/ /apache-storm/

ENV STORM_IMAGE=docker.io/library/storm
ENV STORM_VERSION=2.8.1-jre17
ENV STORM_HOME=/opt/storm
ENV SOTRM_USER_NAME=storm
ENV ZOOKEEPER_IMAGE=docker.io/library/zookeeper
ENV ZOOKEEPER_VERSION=3.9.3-jre-17

RUN python3.12 -m ensurepip && python3.12 -m pip install --upgrade pip

COPY ./lab/ /lab/
RUN chown -R 1000 /lab/
