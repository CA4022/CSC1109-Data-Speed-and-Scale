FROM ghcr.io/ca4022/csc1109-dind-minimal:latest AS sandbox

COPY --from=docker.io/apache/hive:4.1.0 /opt/hive/ /opt/hive/
ENV HADOOP_RUNNER_IMAGE=ghcr.io/ca4022/hadoop
ENV HADOOP_RUNNER_VERSION=3.4.2-lean-jdk17
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop
ENV SPARK_IMAGE=docker.io/library/spark
ENV SPARK_VERSION=4.0.1-scala2.13-java17-python3-ubuntu
ENV HIVE_IMAGE=docker.io/apache/hive
ENV HIVE_VERSION=4.1.0
ENV HIVE_HOME=/opt/hive
ENV HIVE_USER_NAME=hive
ENV PIG_CLASSPATH="$SPARK_HOME/jars/*"
ENV IS_RESUME=false

COPY deploy-stack.service /etc/systemd/system/deploy-stack.service
COPY ./lab/ /lab/
COPY ./stack/ /opt/stack/
WORKDIR /lab/

RUN zypper --non-interactive install maven && \
    zypper clean --all && \
    mvn dependency:copy \
        -Dartifact=org.postgresql:postgresql:42.4.3:jar \
        -DoutputDirectory=/opt/hive/lib/ \
        -Dmdep.stripVersion=true && \
    chmod -R 777 /lab/ && \
    chmod +x /opt/stack/hive-init/init && \
    chmod +x /entrypoint.sh && \
    systemctl enable deploy-stack.service
