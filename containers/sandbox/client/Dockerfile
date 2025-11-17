FROM ghcr.io/ca4022/sandbox-client-noroot:latest

COPY ./CSC1109.md /home/jovyan/CSC1109.md
COPY test /test

COPY --from=ghcr.io/ca4022/csc1109-base-root:latest /root/.bashrc /home/jovyan/.bashrc
COPY --from=ghcr.io/ca4022/csc1109-base-root:latest /root/.brushrc /home/jovyan/.brushrc
COPY --from=ghcr.io/ca4022/csc1109-base-root:latest /root/.vimrc /home/jovyan/.vimrc
COPY --from=ghcr.io/ca4022/csc1109-base-root:latest /root/.zshrc /home/jovyan/.zshrc
COPY --from=ghcr.io/ca4022/csc1109-base-root:latest /root/.config/ /home/jovyan/.config/
COPY --from=ghcr.io/ca4022/csc1109-base-root:latest /root/.local/ /home/jovyan/.local/

RUN chown -R jovyan /home/jovyan/.config/ && \
    chown -R jovyan /home/jovyan/.local/

USER jovyan
WORKDIR /lab/

RUN wget -O /home/jovyan/.local/bin/jq https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-linux-$(uname -m | sed 's/aarch64/arm64/; s/x86_64/amd64/') && \
    chmod +x /home/jovyan/.local/bin/jq && \
    conda env config vars set -n base CLASSPATH=$(hadoop classpath --glob) && \
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    vim +'PlugInstall --sync' +qa && \
    micro -plugin remove cheat && \
    sed -i '/^style: "~/ s#~#/home/jovyan#' /home/jovyan/.config/glow/glow.yml
