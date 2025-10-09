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
        fuse-overlayfs \
        slirp4netns && \
    zypper clean --all && \
    uv tool install podman-compose==${BASE_COMPOSE_VERSION} && \
    touch /etc/containers/nodocker && \
    mkdir -p /var/containers/cache/storage && \
    mkdir -p /var/containers/cache/graph && \
    mkdir -p /var/containers/tmp/image
