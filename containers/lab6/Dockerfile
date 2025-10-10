FROM ghcr.io/ca4022/csc1109-sandbox:latest

COPY ./lab/ /lab/
RUN chown -R 1000 /lab/ && \
    useradd -m $HADOOP_USER_NAME && \
    chown -R $HADOOP_USER_NAME $HADOOP_HOME
