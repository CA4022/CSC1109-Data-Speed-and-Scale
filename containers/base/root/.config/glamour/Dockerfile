ARG BASE_OPENSUSE_VERSION=15.5
FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION} AS base

RUN zypper --non-interactive refresh

FROM base AS glamour-build

COPY ./test.sh /test/test.sh
RUN chmod +x /test/test.sh

RUN zypper --non-interactive install git && \
    zypper clean --all && \
    mkdir -p /root/.config/glamour
WORKDIR /root/.config/glamour
RUN git clone https://github.com/catppuccin/glamour build && \
    cp build/themes/* ./ && \
    rm -r build
