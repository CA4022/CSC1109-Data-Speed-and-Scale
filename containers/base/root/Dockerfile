ARG BASE_OPENSUSE_VERSION=15.6

FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION} AS fzf-builder

RUN zypper --non-interactive install gzip tar wget && \
    zypper clean --all

WORKDIR /fzf
RUN wget https://github.com/junegunn/fzf/releases/download/v0.62.0/fzf-0.62.0-linux_$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/').tar.gz && \
    tar xzf fzf-0.62.0-linux_$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/').tar.gz

FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION} AS base

ARG BASE_OPENSUSE_VERSION
ARG BASE_GCC_VERSION
ARG BASE_BASH_VERSION
ARG BASE_GIT_VERSION
ARG BASE_PODMAN_VERSION
ARG BASE_COMPOSE_VERSION

RUN zypper --non-interactive refresh

FROM base AS core-dependencies

# Bring ARGs into this stage to use them.
ARG BASE_OPENSUSE_VERSION
ARG BASE_GCC_VERSION
ARG BASE_BASH_VERSION
ARG BASE_GIT_VERSION
ARG BASE_PODMAN_VERSION
ARG BASE_COMPOSE_VERSION

# These are the core packages for the environment. They are installed in their own stage
# as they are expected to change infrequently.
RUN zypper --non-interactive addrepo "https://download.opensuse.org/repositories/shells:fish:release:4/${BASE_OPENSUSE_VERSION}/shells:fish:release:4.repo" && \
    zypper --non-interactive --gpg-auto-import-keys refresh && \
    zypper --non-interactive install \
        git-${BASE_GIT_VERSION} \
        gcc-${BASE_GCC_VERSION} \
        bash-${BASE_BASH_VERSION} \
        gzip emacs libgpm2 tar wget && \
    zypper clean --all

ENV LANG="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV PATH="/root/.local/bin:/usr/local/bin:$PATH"

# Add the non-essential user-friendly tools and configurations for students.
# Separated from core because these components are more likely to change.
FROM core-dependencies AS student-environment

# Removing locale data after install shaves ~250MB off final image size
# Mkdir required for emacs XDG runtime issue
RUN if zypper search -x -i "busybox-less" >/dev/null 2>&1; then \
        zypper --non-interactive rm busybox-less; \
    fi && \
    zypper --non-interactive install zsh fish hashdeep starship make wget git glow lsd fd \
        fd-bash-completion ripgrep ripgrep-bash-completion tealdeer-bash-completion \
        symbols-only-nerd-fonts unzip vim && \
    zypper clean --all && \
    wget -O /usr/bin/tldr https://github.com/tealdeer-rs/tealdeer/releases/download/v1.7.2/tealdeer-linux-$(uname -m | sed 's/arm64/aarch64/; s/amd64/x86_64/')-musl && \
    chmod +x /usr/bin/tldr && \
    wget -O yazi.zip https://github.com/sxyazi/yazi/releases/download/v25.5.31/yazi-$(uname -m | sed 's/arm64/aarch64/; s/amd64/x86_64/')-unknown-linux-musl.zip && \
    unzip -j yazi.zip */ya */yazi && \
    mv yazi /usr/local/bin/yazi && \
    mv ya /usr/local/bin/ya && \
    rm yazi.zip && \
    wget -O zellij.tar.gz https://github.com/zellij-org/zellij/releases/download/v0.43.1/zellij-no-web-$(uname -m | sed 's/arm64/aarch64/; s/amd64/x86_64/')-unknown-linux-musl.tar.gz && \
    tar -xzf zellij.tar.gz && \
    mv zellij /usr/local/bin/zellij && \
    rm zellij.tar.gz && \
    mkdir -p /run/user/0 && \
    find /usr/share/locale -maxdepth 1 -mindepth 1 ! -name 'en_US' -exec rm -rf {} +

WORKDIR /root/

# Set up modern shell features
RUN wget https://github.com/reubeno/brush/releases/download/brush-shell-v0.2.23/brush-$(uname -m | sed 's/arm64/aarch64/; s/amd64/x86_64/')-unknown-linux-gnu.tar.gz && \
    tar -xzf brush-$(uname -m | sed 's/arm64/aarch64/; s/amd64/x86_64/')-unknown-linux-gnu.tar.gz && \
    rm brush-$(uname -m | sed 's/arm64/aarch64/; s/amd64/x86_64/')-unknown-linux-gnu.tar.gz && \
    mv brush /usr/bin/brush && \
    rm LICENSE && \
    rm THIRD_PARTY_LICENSES.html && \
    rm -r bin && \
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# Pre-install vim plugins
COPY .vimrc .vimrc
RUN vim +'PlugInstall --sync' +qa

# Move across test files and make them executable
COPY ./test/ /test/
COPY ./.config/micro/test.sh /test/base/editor_tests/micro_test.sh
COPY ./.config/emacs/test.sh /test/base/editor_tests/micro_test.sh
COPY ./.config/nvim/test.sh /test/base/editor_tests/micro_test.sh
RUN chmod -R +x /test/

COPY .bashrc .bashrc
COPY .brushrc .brushrc
COPY .zshrc .zshrc
COPY .config/starship .config/starship
COPY .config/glow .config/glow
COPY .config/tealdeer .config/tealdeer
COPY .local/share/tealdeer/pages/csc1109.page.md .local/share/tealdeer/pages/csc1109.page.md
COPY .config/fish .config/fish
COPY .config/nushell .config/nushell

COPY --from=fzf-builder /fzf/fzf /usr/local/bin/fzf

COPY --from=ghcr.io/nushell/nushell:0.105.1-bookworm /bin/nu /bin/nu/
COPY --from=ghcr.io/nushell/nushell:0.105.1-bookworm /usr/bin/nu /usr/bin/

COPY --from=ghcr.io/ca4022/csc1109-base-root-config-bat:latest /usr/bin/bat /usr/bin/bat
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-bat:latest /usr/share/man/man1/bat.1.gz /usr/share/man/man1/bat.1.gz
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-bat:latest /usr/local/ /usr/local/
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-micro:latest /usr/bin/micro /usr/bin/micro
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-micro:latest /usr/local/ /usr/local/
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-emacs:latest /usr/bin/emacs /usr/bin/emacs
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-emacs:latest /usr/bin/emacsclient /usr/bin/emacsclient
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-emacs:latest /usr/bin/emacs-nox /usr/bin/emacs-nox
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-emacs:latest /usr/lib/emacs /usr/lib/emacs
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-emacs:latest /usr/share/emacs /usr/share/emacs
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-emacs:latest /var/games/emacs /var/games/emacs
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-emacs:latest /usr/share/man/man1/emacs.1.gz /usr/share/man/man1/emacs.1.gz
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-emacs:latest /usr/share/info/emacs.info.gz /usr/share/info/emacs.info.gz
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-emacs:latest /usr/local/ /usr/local/
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-nvim:latest /bin/nvim /bin/nvim
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-nvim:latest /lib/nvim /lib/nvim
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-nvim:latest /share/nvim /share/nvim
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-nvim:latest /share/man /share/man
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-nvim:latest /usr/local/ /usr/local/

COPY --from=ghcr.io/ca4022/csc1109-base-root-config-glamour:latest /root/ /root/
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-bat:latest /root/ /root/
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-micro:latest /root/ /root/
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-emacs:latest /root/ /root/
COPY --from=ghcr.io/ca4022/csc1109-base-root-config-nvim:latest /root/ /root/

COPY ./CSC1109.md /root/CSC1109.md

RUN rm -r /root/bin
