FROM ghcr.io/ca4022/csc1109-base:latest AS base

ARG BASE_OPENSUSE_VERSION
ARG BASE_PODMAN_VERSION
ARG BASE_COMPOSE_VERSION

COPY ./storage.conf /etc/containers/storage.conf
COPY ./containers.conf /etc/containers/containers.conf

RUN zypper --non-interactive addrepo https://download.opensuse.org/repositories/Virtualization:containers/${BASE_OPENSUSE_VERSION}/Virtualization:containers.repo && \
    zypper --non-interactive --gpg-auto-import-keys refresh && \
    zypper --non-interactive install \
        podman-${BASE_PODMAN_VERSION} \
        podman-docker-${BASE_PODMAN_VERSION} \
        fuse-overlayfs && \
    zypper clean --all && \
    curl -o /usr/local/bin/podman-compose https://raw.githubusercontent.com/containers/podman-compose/refs/tags/${BASE_PODMAN_VERSION}/podman_compose.py && \
    sed -i -e '1s|^#!/usr/bin/env python3$|#!/usr/bin/env python3.12|' /usr/local/bin/podman-compose && \
    chmod +x /usr/local/bin/podman-compose && \
    touch /etc/containers/nodocker

