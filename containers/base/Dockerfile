ARG BASE_OPENSUSE_VERSION=15.5
FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION} AS base

ARG BASE_OPENSUSE_VERSION
ARG BASE_GCC_VERSION
ARG BASE_BASH_VERSION
ARG BASE_GIT_VERSION
ARG BASE_DOCKER_VERSION
ARG BASE_COMPOSE_VERSION

RUN zypper --non-interactive refresh

# These are the core packages for the environment. They are installed in their own stage
# as they are expected to change infrequently.
FROM base AS core-dependencies

# Bring ARGs into this stage to use them.
ARG BASE_OPENSUSE_VERSION
ARG BASE_GCC_VERSION
ARG BASE_BASH_VERSION
ARG BASE_GIT_VERSION
ARG BASE_DOCKER_VERSION
ARG BASE_COMPOSE_VERSION

RUN zypper --non-interactive addrepo "https://download.opensuse.org/repositories/Virtualization:containers/${BASE_OPENSUSE_VERSION}/Virtualization:containers.repo" && \
    zypper --non-interactive --gpg-auto-import-keys refresh && \
    zypper --non-interactive install \
        bash-${BASE_BASH_VERSION} \
        gcc-${BASE_GCC_VERSION} \
        git-${BASE_GIT_VERSION} \
        docker-${BASE_DOCKER_VERSION} \
        docker-compose-${BASE_COMPOSE_VERSION} \
        python312 && \
    zypper clean --all

# Add the non-essential user-friendly tools and configurations for students.
# Separated from core because these components are more likely to change.
FROM core-dependencies AS student-environment

RUN zypper --non-interactive install \
        wget \
        bat bat-bash-completion \
        glow \
        lsd \
        fd fd-bash-completion \
        ripgrep ripgrep-bash-completion \
        tealdeer tealdeer-bash-completion \
        symbols-only-nerd-fonts \
        vim \
        docker-bash-completion && \
    zypper clean --all

COPY --from=ghcr.io/nushell/nushell:0.105.1-bookworm /bin/nu /bin/nu_plugin* /usr/local/bin/
RUN bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)" "" --unattended

COPY ./root/ /root/
RUN chmod +x /root/build.sh && /root/build.sh && rm /root/build.sh && \
    chmod +x /root/.config/bat/build.sh && /root/.config/bat/build.sh && rm /root/.config/bat/build.sh && \
    chmod +x /root/.config/glamour/build.sh && /root/.config/glamour/build.sh && rm /root/.config/glamour/build.sh && \
    chmod +x /root/.config/micro/build.sh && /root/.config/micro/build.sh && rm /root/.config/micro/build.sh && \
    chmod +x /root/.config/nvim/build.sh && /root/.config/nvim/build.sh && rm /root/.config/nvim/build.sh && \
    mkdir -p /run/user/0 && chmod +x /root/.config/emacs/build.sh && /root/.config/emacs/build.sh && rm /root/.config/emacs/build.sh

# Assembly stage: copy over application-specific code, tests, and entrypoint.
# These files are expected to change most frequently.
FROM student-environment AS final

# Install test-specific dependencies.
RUN zypper --non-interactive install hashdeep jq && zypper clean --all

# Copy test files and set permissions.
COPY ./test/ /test/
RUN chmod -R +x /test/

# Create working directory and a directory needed to suppress emacs warnings.
RUN mkdir /lab
WORKDIR /lab

# Copy lab specific files and set entrypoint running
COPY ./lab/ /lab/
COPY entrypoint.py /entrypoint.py
RUN chmod +x /entrypoint.py
CMD ["/entrypoint.py"]
