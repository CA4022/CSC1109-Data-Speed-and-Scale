ARG BASE_OPENSUSE_VERSION=15.5
FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION} AS base

RUN zypper --non-interactive refresh

FROM base AS nvim-build

RUN zypper --non-interactive install gcc git gzip lua54 lua54-devel make unzip tar wget && \
    zypper clean --all

# Install neovim from tarball (SUSE Leap version is woefully out of date)
RUN mkdir /nvim
WORKDIR /nvim
RUN wget -O nvim.tar.gz https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-$(uname -m | sed 's/aarch64/arm64/; s/amd64/x86_64/').tar.gz && \
    tar xf nvim.tar.gz && \
    cp -r nvim-linux-$(uname -m | sed 's/aarch64/arm64/; s/amd64/x86_64/')/* / && \
    rm -r nvim-linux-$(uname -m | sed 's/aarch64/arm64/; s/amd64/x86_64/')

# Install neovim plugins at container build time
# First: bootstrap lazy.nvim using luarocks
WORKDIR /
RUN wget -O luarocks.tar.gz https://luarocks.org/releases/luarocks-3.13.0.tar.gz && \
    tar zxpf luarocks.tar.gz && \
    rm luarocks.tar.gz
WORKDIR luarocks
RUN ./configure && make && make install
WORKDIR /
RUN rm -r luarocks && \
    luarocks install lazy.nvim

COPY . /root/.config/nvim

# Finally, headlessly bootstrap the neovim setup
RUN curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua | nvim --headless +qa -c -

COPY ./test.sh /test/test.sh
RUN chmod -R +x /test/
COPY ./init.lua /root/.config/nvim/init.lua
