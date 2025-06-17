ARG BASE_OPENSUSE_VERSION=15.5
FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION} AS base

RUN zypper --non-interactive refresh

FROM base as bat-build

RUN zypper --non-interactive install bat wget && \
    zypper clean --all && \
    mkdir -p /root/.config/bat/themes

WORKDIR /root/.config/bat/themes

RUN wget https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme && \
    wget https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme && \
    wget https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme && \
    wget https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme && \
    bat cache --build

WORKDIR /root/.config/bat

RUN touch /test/test.sh # Create a dummy test script
COPY --exclude=Dockerfile,VERSION . .
