FROM ghcr.io/ca4022/csc1109-base:latest AS base

ARG BASE_OPENSUSE_VERSION
ARG BASE_PODMAN_VERSION
ARG BASE_COMPOSE_VERSION

COPY ./storage.conf /etc/containers/storage.conf

RUN zypper --non-interactive addrepo https://download.opensuse.org/repositories/Virtualization:containers/${BASE_OPENSUSE_VERSION}/Virtualization:containers.repo && \
    zypper --non-interactive --gpg-auto-import-keys refresh && \
    zypper --non-interactive install \
        podman-${BASE_PODMAN_VERSION} \
        podman-docker-${BASE_PODMAN_VERSION} \
        python311-podman-compose-${BASE_COMPOSE_VERSION} \
        fuse-overlayfs && \
    zypper clean --all

