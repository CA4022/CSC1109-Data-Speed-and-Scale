FROM ghcr.io/ca4022/csc1109-base:latest AS base

ARG BASE_PODMAN_VERSION
ARG BASE_COMPOSE_VERSION

COPY ./storage.conf /etc/containers/storage.conf

RUN zypper --non-interactive refresh && \
    zypper --non-interactive install \
        podman-${BASE_PODMAN_VERSION} \
        podman-compose-${BASE_COMPOSE_VERSION} && \
    zypper clean --all

