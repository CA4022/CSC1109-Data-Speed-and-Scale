FROM ghcr.io/ca4022/csc1109-sandbox-client-jupyter:latest AS sandbox-client-noroot-base

ENV HADOOP_HOME="/opt/hadoop"
ENV HADOOP_USER_NAME="hadoop"
ENV HIVE_HOME="/opt/hive"
ENV HIVE_USER_NAME="hive"
ENV PIG_HOME="/opt/pig/"
ENV PATH="/home/jovyan/.local/bin/:/home/jovyan/.cargo/bin/:/opt/hadoop/bin/:/opt/hive/bin/:/opt/pig/bin/:/opt/maven/bin/:$PATH"

COPY ./entrypoint.py /entrypoint.py
COPY ./bin/brush-hl /bin/brush-hl

FROM sandbox-client-noroot-base AS sandbox-client-noroot-build

USER root

ENV BUILD_DEPS="gnupg2 software-properties-common build-essential pkg-config libssl-dev rustup luarocks"

RUN DEBIAN_FRONTEND=noninteractive \
    chmod +x /entrypoint.py && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        ca-certificates \
        zsh \
        emacs \
        vim \
        micro \
        bat \
        fd-find \
        ripgrep \
        fzf \
        tealdeer \
        $BUILD_DEPS && \
    curl -fsSL "https://apt.fury.io/nushell/gpg.key" | gpg --dearmor -o /etc/apt/trusted.gpg.d/fury-nushell.gpg && \
    echo "deb https://apt.fury.io/nushell/ /" | tee /etc/apt/sources.list.d/fury.list && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL "https://repo.charm.sh/apt/gpg.key" | gpg --dearmor -o /etc/apt/keyrings/charm.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list && \
    add-apt-repository ppa:neovim-ppa/unstable && \
    add-apt-repository ppa:fish-shell/release-4 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        fish \
        glow \
        nushell \
        neovim && \
    ln -s /bin/batcat /bin/bat && \
    luarocks install lazy.nvim && \
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b /usr/local/bin && \
    rustup default stable && \
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash && \
    cargo binstall brush-shell lsd && \
    rustup default none && \
    rm -r /home/jovyan/.rustup && \
    apt-get purge -y --auto-remove $BUILD_DEPS && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/apt/sources.list.d/fury.list \
          /etc/apt/sources.list.d/charm.list \
          /etc/apt/sources.list.d/neovim-ppa-unstable.list \
          /etc/apt/trusted.gpg.d/fury-nushell.gpg \
          /etc/apt/keyrings/charm.gpg && \
    groupadd hive && \
    groupadd hadoop && \
    usermod -aG hive,hadoop jovyan && \
    chown -R jovyan /home/jovyan/.jupyter/ && \
    mkdir -p /home/jovyan/.local/ && \
    chown -R jovyan /home/jovyan/.local/ && \
    chmod +x /test/test.sh

FROM sandbox-client-noroot-build AS sandbox-client-noroot-final

COPY --from=ghcr.io/ca4022/csc1109-sandbox-client-apache:latest /opt/hadoop/ /opt/hadoop/
COPY --from=ghcr.io/ca4022/csc1109-sandbox-client-apache:latest /opt/hive/ /opt/hive/
COPY --from=ghcr.io/ca4022/csc1109-sandbox-client-apache:latest /opt/pig/ /opt/pig/

