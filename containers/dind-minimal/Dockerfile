ARG BASE_OPENSUSE_VERSION=15.6

FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION} AS base

ARG BASE_BASH_VERSION
ARG BASE_PODMAN_VERSION
ARG BASE_COMPOSE_VERSION

RUN zypper --non-interactive refresh

FROM base AS dind-minimal

ARG BASE_OPENSUSE_VERSION=15.6
ARG BASE_BASH_VERSION
ARG BASE_PODMAN_VERSION
ARG BASE_COMPOSE_VERSION

COPY ./storage.conf /etc/containers/storage.conf
COPY ./containers.conf /etc/containers/containers.conf

RUN zypper --non-interactive addrepo https://download.opensuse.org/repositories/Virtualization:containers/${BASE_OPENSUSE_VERSION}/Virtualization:containers.repo && \
    zypper --non-interactive --gpg-auto-import-keys refresh && \
    zypper --non-interactive install \
        bash-${BASE_BASH_VERSION} \
        podman-${BASE_PODMAN_VERSION} \
        podman-docker-${BASE_PODMAN_VERSION} \
        fuse-overlayfs \
        nftables && \
    zypper clean --all && \
    curl -o /usr/local/bin/podman-compose https://raw.githubusercontent.com/containers/podman-compose/refs/tags/${BASE_PODMAN_VERSION}/podman_compose.py && \
    sed -i -e '1s|^#!/usr/bin/env python3$|#!/usr/bin/env python3.12|' /usr/local/bin/podman-compose && \
    chmod +x /usr/local/bin/podman-compose && \
    touch /etc/containers/nodocker

COPY test.sh /test/test.sh
RUN chmod +x /test/test.sh
