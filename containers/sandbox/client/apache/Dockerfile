FROM docker.io/apache/hadoop:3.4.1

ENV PIG_HOME="/opt/pig/"

COPY test /test

COPY --from=docker.io/apache/hive:4.0.1 /opt/hive/ /opt/hive/

USER root

RUN chmod +x /test/test.sh && \
    wget https://downloads.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz && \
    tar -xzf pig-0.17.0.tar.gz && \
    rm pig-0.17.0.tar.gz && \
    mv pig-0.17.0 $PIG_HOME && \
    echo "exectype=spark" >> $PIG_HOME/conf/pig.properties

USER hadoop
