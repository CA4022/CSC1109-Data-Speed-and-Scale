ARG BASE_OPENSUSE_VERSION=15.5
FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION} AS base

RUN zypper --non-interactive refresh

FROM base as nvim-build

RUN zypper --non-interactive install gcc git gzip lua53 lua53-devel make unzip tar wget && \
    zypper clean --all

# Install neovim from tarball (SUSE Leap version is woefully out of date)
RUN mkdir /nvim
WORKDIR /nvim
RUN wget https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz && \
    tar xf nvim-linux-x86_64.tar.gz && \
    cp -r nvim-linux-x86_64/* / && \
    rm -r /nvim

# Install neovim plugins at container build time
# First: bootstrap lazy.nvim using luarocks
WORKDIR /
RUN wget https://luarocks.org/releases/luarocks-3.12.0.tar.gz && \
    tar zxpf luarocks-3.12.0.tar.gz
WORKDIR luarocks-3.12.0
RUN ./configure && make && make install
WORKDIR /
RUN rm -r luarocks-3.12.0 && \
    luarocks install lazy.nvim

COPY . /root/.config/nvim

# Finally, headlessly bootstrap the neovim setup
RUN curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua | nvim --headless +qa -c -

COPY ./test.sh /test/test.sh
RUN chmod -R +x /test/
COPY --exclude=Dockerfile,VERSION,test.sh . .
