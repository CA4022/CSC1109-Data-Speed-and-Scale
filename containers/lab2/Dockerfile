FROM ghcr.io/ca4022/csc1109-dind:latest AS lab2-environment

COPY --from=docker.io/apache/hive:4.2.1 /opt/hive/ /opt/hive/
ENV HADOOP_RUNNER_IMAGE=ghcr.io/ca4022/hadoop
ENV HADOOP_RUNNER_VERSION=3.5.0
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop
ENV HIVE_IMAGE=ghcr.io/ca4022/hive
ENV HIVE_VERSION=4.2.1
ENV HIVE_HOME=/opt/hive
ENV HIVE_USER_NAME=hive
ENV TEZ_VERSION=0.10.5
ENV IS_RESUME=false

COPY ./lab/ /lab/
RUN chown -R 1000 /lab/ && \
    mvn dependency:copy \
        -Dartifact=org.postgresql:postgresql:42.4.3:jar \
        -DoutputDirectory=/opt/hive/lib/ \
        -Dmdep.stripVersion=true && \
    wget -q -O /opt/tez.tar.gz \
        "https://dlcdn.apache.org/tez/${TEZ_VERSION}/apache-tez-${TEZ_VERSION}-bin.tar.gz" && \
    mkdir -p /opt/tez && \
    tar -xzf /opt/tez.tar.gz -C /opt/tez --strip-components=1
