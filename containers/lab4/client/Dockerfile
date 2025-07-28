FROM ghcr.io/amileo/csc1109-base

RUN groupadd storm && \
    groupadd hadoop && \
    useradd -g storm -g hadoop -k /root/ -m storm

USER storm
