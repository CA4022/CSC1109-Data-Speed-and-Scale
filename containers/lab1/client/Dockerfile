FROM ghcr.io/ca4022/csc1109-base

ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop

COPY --from=ghcr.io/ca4022/hadoop:3.4.2-lean-jdk17 /opt/hadoop/ /opt/hadoop/

RUN groupadd hadoop && \
    useradd -g $HADOOP_USER_NAME -k /root/ -m $HADOOP_USER_NAME && \
    chown -R $HADOOP_USER_NAME $HADOOP_HOME

USER $HADOOP_USER_NAME
