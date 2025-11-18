FROM ghcr.io/ca4022/csc1109-base

COPY --from=ghcr.io/ca4022/hadoop:3.4.2-lean /opt/hadoop/ /opt/hadoop/

RUN groupadd hadoop && \
    useradd -g hadoop -k /root/ -m hadoop

USER hadoop
