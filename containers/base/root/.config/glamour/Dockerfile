ARG BASE_OPENSUSE_VERSION=15.5
FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION} AS base

RUN zypper --non-interactive refresh

FROM base AS glamour-build

RUN zypper --non-interactive install git && \
    zypper clean --all && \
    mkdir -p /root/.config/glamour
WORKDIR /root/.config/glamour
RUN git clone https://github.com/catppuccin/glamour build && \
    cp build/themes/* ./ && \
    rm -r build && \
    mkdir /touch && \
    touch /test/test.sh # Create a dummy test script
