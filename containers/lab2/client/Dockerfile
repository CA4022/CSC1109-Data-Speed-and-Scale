FROM ghcr.io/ca4022/csc1109-base

COPY --from=ghcr.io/ca4022/hadoop:3.4.2-lean-jdk17 /opt/hadoop/ /opt/hadoop/

RUN groupadd hive && \
    groupadd hadoop && \
    useradd -g hive -g hadoop -k /root/ -m hive

USER hive
