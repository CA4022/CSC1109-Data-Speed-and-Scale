FROM ghcr.io/ca4022/csc1109-base

RUN groupadd hive && \
    groupadd hadoop && \
    useradd -g hive -g hadoop -k /root/ -m hive

USER hive
