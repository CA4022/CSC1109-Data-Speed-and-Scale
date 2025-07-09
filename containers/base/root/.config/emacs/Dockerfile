ARG BASE_OPENSUSE_VERSION=15.5
FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION} AS base

RUN zypper --non-interactive refresh

FROM base AS emacs-build

RUN zypper --non-interactive install emacs git && \
    zypper clean --all && \
    mkdir -p /root/.config/emacs

WORKDIR /root/.config/emacs

COPY ./test.sh /test/test.sh
RUN chmod -R +x /test/
COPY ./early-init.el /root/.config/emacs/early-init.el
COPY ./init.el /root/.config/emacs/init.el
RUN emacs --batch -l ./init.el
WORKDIR straight/repos
RUN for repo in */; do (cd "$repo" && echo "Compacting $repo" && git gc --aggressive --prune=now); done
