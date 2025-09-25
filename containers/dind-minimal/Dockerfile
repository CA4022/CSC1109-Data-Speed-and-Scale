ARG BASE_OPENSUSE_VERSION=15.6

FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION} AS base

ARG BASE_BASH_VERSION
ARG BASE_PODMAN_VERSION
ARG BASE_COMPOSE_VERSION

RUN zypper --non-interactive refresh

FROM base AS dind-minimal

ARG BASE_BASH_VERSION
ARG BASE_PODMAN_VERSION
ARG BASE_COMPOSE_VERSION

RUN zypper --non-interactive --gpg-auto-import-keys refresh && \
    zypper --non-interactive install \
        bash-${BASE_BASH_VERSION} \
        podman-${BASE_PODMAN_VERSION} \
        podman-docker-${BASE_PODMAN_VERSION} \
        python311-podman-compose-${BASE_COMPOSE_VERSION} && \
    zypper clean --all

COPY test.sh /test/test.sh
RUN chmod +x /test/test.sh
