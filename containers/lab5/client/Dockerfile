FROM ghcr.io/ca4022/csc1109-base

COPY --from=docker.io/library/spark:4.0.0-scala2.13-java17-python3-ubuntu /opt/ /opt/
COPY --from=ghcr.io/ca4022/hadoop:3.4.2-lean-jdk17 /opt/hadoop/ /opt/hadoop/
COPY ./spark-defaults.conf /opt/spark/conf/spark-defaults.conf

RUN groupadd spark && \
    groupadd hadoop && \
    useradd -g spark -g hadoop -k /root/ -m spark

ENV SPARK_HOME=/opt/spark/
ENV SPARK_LOCAL_IP="127.0.0.1"

ENTRYPOINT default_shell
USER spark
