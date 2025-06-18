ARG BASE_OPENSUSE_VERSION=15.5
FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION} AS base

ARG BASE_OPENSUSE_VERSION

RUN zypper --non-interactive refresh

FROM base AS micro-build

ARG BASE_OPENSUSE_VERSION

RUN zypper --non-interactive addrepo https://download.opensuse.org/repositories/devel:languages:go/${BASE_OPENSUSE_VERSION}/devel:languages:go.repo && \
    zypper --non-interactive --gpg-auto-import-keys refresh && \
    zypper --non-interactive install git jq micro-editor && \
    zypper clean --all && \
    mkdir -p /root/.config/micro/colorschemes

WORKDIR /root/.config/micro

RUN git clone https://github.com/catppuccin/micro /root/.config/micro/catppuccin

WORKDIR /root/.config/micro/catppuccin
RUN git checkout 2802b32 && cp src/* ../colorschemes/
WORKDIR /root/.config/micro

RUN rm -r catppuccin && \
    micro -plugin install filemanager lsp autofmt detectindent fzf jump bounce cheat

COPY ./test.sh /test/test.sh
RUN chmod -R +x /test/
COPY ./settings.json /root/.config/micro/settings.json
COPY ./bindings.json /root/.config/micro/bindings.json
