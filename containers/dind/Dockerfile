FROM ghcr.io/ca4022/csc1109-base:latest AS base

ARG BASE_DOCKER_VERSION
ARG BASE_COMPOSE_VERSION

RUN zypper --non-interactive refresh && \
    zypper --non-interactive install \
        docker-${BASE_DOCKER_VERSION} \
        docker-compose-${BASE_COMPOSE_VERSION} \
        fuse-overlayfs && \
    zypper clean --all

