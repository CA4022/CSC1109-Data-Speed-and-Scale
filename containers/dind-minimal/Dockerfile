ARG BASE_OPENSUSE_VERSION=15.6

FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION} AS base

ARG BASE_OPENSUSE_VERSION
ARG BASE_DOCKER_VERSION
ARG BASE_COMPOSE_VERSION

RUN zypper --non-interactive refresh

FROM base AS dind-minimal

ARG BASE_OPENSUSE_VERSION
ARG BASE_DOCKER_VERSION
ARG BASE_COMPOSE_VERSION

RUN zypper --non-interactive addrepo "https://download.opensuse.org/repositories/Virtualization:containers/${BASE_OPENSUSE_VERSION}/Virtualization:containers.repo" && \
    zypper --non-interactive --gpg-auto-import-keys refresh && \
    zypper --non-interactive install \
        docker-${BASE_DOCKER_VERSION} \
        docker-compose-${BASE_COMPOSE_VERSION} \
        fuse-overlayfs && \
    zypper clean --all && \
    mkdir -p /test/ && \
    echo "echo 'No tests implemented!'" >> /test/test.sh && \
    chmod +x /test/test.sh
