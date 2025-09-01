FROM ghcr.io/ca4022/csc1109-base:latest AS lab1-environment

RUN zypper --non-interactive install \
        erlang \
        elixir \
        elixir-hex && \
    zypper clean --all

COPY ./lab/ /lab/
