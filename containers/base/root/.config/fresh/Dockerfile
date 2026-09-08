ARG BASE_OPENSUSE_VERSION=15.5
FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION} AS base

RUN zypper --non-interactive refresh

FROM base AS fresh-build

COPY ./test.sh /test/test.sh
RUN chmod +x /test/test.sh

RUN zypper --non-interactive install git && \
    zypper clean --all && \
    mkdir -p /root/.config/fresh
WORKDIR /root/.config/fresh
RUN git clone https://github.com/milon/catppuccin-fresh build && \
    mkdir ./themes && \
    cp build/*.json ./themes/ && \
    rm -r build
COPY ./config.json ./config.json
