ARG BASE_OPENSUSE_VERSION
FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION}

ARG HOSTNAME="base"
ARG BASE_OPENSUSE_VERSION
ARG BASE_GCC_VERSION
ARG BASE_BASH_VERSION
ARG BASE_GIT_VERSION
ARG BASE_DOCKER_VERSION
ARG BASE_COMPOSE_VERSION

# Install core packages
RUN zypper --non-interactive addrepo "https://download.opensuse.org/repositories/Virtualization:containers/${BASE_OPENSUSE_VERSION}/Virtualization:containers.repo"
RUN zypper --non-interactive --gpg-auto-import-keys refresh
RUN zypper --non-interactive install bash-${BASE_BASH_VERSION} gcc-${BASE_GCC_VERSION} git-${BASE_GIT_VERSION} docker-${BASE_DOCKER_VERSION} docker-compose-${BASE_COMPOSE_VERSION}

# Install non-essential environment elements
# NOTE: A goal here is to provide a consistent, user friendly environment for students
#     to work within. As such, these don't need to be pinned and are likely to change
#     more often than the rest of this file.
RUN zypper addrepo https://download.opensuse.org/repositories/devel:languages:go/${BASE_OPENSUSE_VERSION}/devel:languages:go.repo
RUN zypper --non-interactive --gpg-auto-import-keys refresh
RUN zypper --non-interactive install emacs micro-editor fzf symbols-only-nerd-fonts docker-bash-completion
RUN zypper --non-interactive install wget
RUN mkdir /nvim
WORKDIR /nvim
RUN wget https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz
RUN tar xf nvim-linux-x86_64.tar.gz
RUN cp -r nvim-linux-x86_64/* /
WORKDIR /
RUN rm -r /nvim
RUN bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"
COPY ./root/.bashrc /root/.bashrc
COPY ./root/.config/nvim/init.lua /root/.config/nvim/init.lua

# Set working directory
RUN mkdir /lab
WORKDIR /lab

# Prepare entrypoint to initialise environment
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Run interactuve shell
CMD ["bash"]
