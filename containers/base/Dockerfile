ARG BASE_OPENSUSE_VERSION
FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION}

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
# First, lets install some modern unix tooling and convenience elements
RUN zypper --non-interactive install wget fzf bat bat-bash-completion glow lsd fd fd-bash-completion ripgrep ripgrep-bash-completion tealdeer tealdeer-bash-completion symbols-only-nerd-fonts vim docker-bash-completion
# Build bash env
RUN bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"
# Copy across config files
COPY ./root/build.sh /root/build.sh
COPY ./root/.bashrc /root/.bashrc
COPY ./root/.blerc /root/.blerc
COPY ./root/.config/ /root/.config/
# Build bash env
RUN chmod +x /root/build.sh
RUN /root/build.sh
RUN rm /root/build.sh
# Build bat env
RUN chmod +x /root/.config/bat/build.sh
RUN /root/.config/bat/build.sh
RUN rm /root/.config/bat/build.sh
# Build glamour theming env
RUN chmod +x /root/.config/glamour/build.sh
RUN /root/.config/glamour/build.sh
RUN rm /root/.config/glamour/build.sh
# Build micro env
RUN chmod +x /root/.config/micro/build.sh
RUN /root/.config/micro/build.sh
RUN rm /root/.config/micro/build.sh
# Build neovim env
RUN chmod +x /root/.config/nvim/build.sh
RUN /root/.config/nvim/build.sh
RUN rm /root/.config/nvim/build.sh
# Build emacs env
RUN chmod +x /root/.config/emacs/build.sh
RUN /root/.config/emacs/build.sh
RUN rm /root/.config/emacs/build.sh

# Set working directory
RUN mkdir /lab
WORKDIR /lab

# Prepare entrypoint to initialise environment
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Run interactive shell
CMD ["bash"]
