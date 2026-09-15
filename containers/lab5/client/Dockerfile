FROM ghcr.io/ca4022/csc1109-base

COPY --from=ghcr.io/ca4022/spark:4.2.0-scala2.13-java21-python3-ubuntu /opt/ /opt/
COPY --from=ghcr.io/ca4022/hadoop:3.5.0 /opt/hadoop/ /opt/hadoop/
COPY ./spark-defaults.conf /opt/spark/conf/spark-defaults.conf

RUN groupadd spark && \
    groupadd hadoop && \
    useradd -g spark -g hadoop -k /root/ -m spark && \
    mkdir -p /var/cache/javasharedresources && \
    chmod 1777 /var/cache/javasharedresources

ENV SPARK_HOME=/opt/spark/
ENV SPARK_LOCAL_IP="127.0.0.1"

USER spark
