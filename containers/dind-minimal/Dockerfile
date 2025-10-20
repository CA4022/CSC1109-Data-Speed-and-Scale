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
COPY --from=ghcr.io/astral-sh/uv:0.7.13 /uv /uvx /bin/
COPY entrypoint.sh /entrypoint.sh

ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

RUN zypper --non-interactive addrepo https://download.opensuse.org/repositories/Virtualization:containers/${BASE_OPENSUSE_VERSION}/Virtualization:containers.repo && \
    zypper --non-interactive --gpg-auto-import-keys refresh && \
    zypper --non-interactive install --no-recommends systemd && \
    zypper --non-interactive install \
        bash-${BASE_BASH_VERSION} \
        podman-${BASE_PODMAN_VERSION} \
        podman-docker-${BASE_PODMAN_VERSION} \
        fuse-overlayfs \
        iptables \
        slirp4netns && \
    zypper clean --all && \
    uv tool install podman-compose==${BASE_COMPOSE_VERSION} && \
    chmod +x /entrypoint.sh && \
    systemctl mask \
        getty@.service \
        serial-getty@.service \
        getty.target \
        proc-sys-fs-binfmt_misc.automount \
        sys-kernel-debug.mount \
        sys-kernel-tracing.mount \
        sys-kernel-config.mount && \
    touch /etc/containers/nodocker && \
    mkdir -p /var/containers/cache/storage && \
    mkdir -p /var/containers/cache/graph && \
    mkdir -p /var/containers/tmp/image

COPY test.sh /test/test.sh
RUN chmod +x /test/test.sh

STOPSIGNAL SIGRTMIN+3

CMD ["/entrypoint.sh"]
