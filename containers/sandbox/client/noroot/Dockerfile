FROM ghcr.io/ca4022/csc1109-sandbox-client-noroot-jupyter:latest AS sandbox-client-noroot-base

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
        $BUILD_DEPS && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL "https://repo.charm.sh/apt/gpg.key" | gpg --dearmor -o /etc/apt/keyrings/charm.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | tee /etc/apt/sources.list.d/sbt.list && \
    echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | tee /etc/apt/sources.list.d/sbt_old.list && \
    curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | tee /etc/apt/trusted.gpg.d/sbt.asc && \
    add-apt-repository ppa:neovim-ppa/unstable && \
    add-apt-repository ppa:fish-shell/release-4 && \
    apt-get update && \
    rustup set profile minimal && \
    rustup default stable && \
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash && \
    cargo binstall brush-shell lsd && \
    rustup default none && \
    rm -r /home/jovyan/.rustup && \
    apt-get install -y --no-install-recommends \
        maven \
        sbt \
        zsh \
        emacs \
        vim \
        micro \
        bat \
        fd-find \
        ripgrep \
        fzf \
        tealdeer \
        fish \
        glow \
        neovim && \
    curl -sL $(curl -s https://api.github.com/repos/sinelaw/fresh/releases/latest | grep "browser_download_url.*_$(dpkg --print-architecture)\.deb" | cut -d '"' -f 4) -o fresh-editor.deb && \
    dpkg -i fresh-editor.deb && \
    rm fresh-editor.deb && \
    ln -s /bin/batcat /bin/bat && \
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b /usr/local/bin && \
    luarocks install lazy.nvim && \
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

FROM sandbox-client-noroot-build AS sandbox-client-noroot-nocopy

COPY --from=ghcr.io/nushell/nushell:0.108.0-bookworm /usr/bin/nu /usr/bin/nu
COPY --from=ghcr.io/nushell/nushell:0.108.0-bookworm /usr/bin/nu_plugin_custom_values /usr/bin/nu_plugin_custom_values
COPY --from=ghcr.io/nushell/nushell:0.108.0-bookworm /usr/bin/nu_plugin_example /usr/bin/nu_plugin_example
COPY --from=ghcr.io/nushell/nushell:0.108.0-bookworm /usr/bin/nu_plugin_formats /usr/bin/nu_plugin_formats
COPY --from=ghcr.io/nushell/nushell:0.108.0-bookworm /usr/bin/nu_plugin_gstat /usr/bin/nu_plugin_gstat
COPY --from=ghcr.io/nushell/nushell:0.108.0-bookworm /usr/bin/nu_plugin_inc /usr/bin/nu_plugin_inc
COPY --from=ghcr.io/nushell/nushell:0.108.0-bookworm /usr/bin/nu_plugin_polars /usr/bin/nu_plugin_polars
COPY --from=ghcr.io/nushell/nushell:0.108.0-bookworm /usr/bin/nu_plugin_query /usr/bin/nu_plugin_query
COPY --from=ghcr.io/nushell/nushell:0.108.0-bookworm /usr/bin/nu_plugin_stress_internals /usr/bin/nu_plugin_stress_internals

FROM sandbox-client-noroot-build AS sandbox-client-noroot-final

COPY --from=ghcr.io/ca4022/csc1109-sandbox-client-apache:latest /opt/hadoop/ /opt/hadoop/
COPY --from=ghcr.io/ca4022/csc1109-sandbox-client-apache:latest /opt/hive/ /opt/hive/
COPY --from=ghcr.io/ca4022/csc1109-sandbox-client-apache:latest /opt/pig/ /opt/pig/

