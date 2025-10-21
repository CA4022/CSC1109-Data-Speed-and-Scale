FROM ghcr.io/ca4022/csc1109-sandbox-client-jupyter:latest AS sandbox-client-base

ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
ENV HADOOP_HOME="/opt/hadoop"
ENV HADOOP_USER_NAME="hadoop"
ENV HIVE_HOME="/opt/hive"
ENV HIVE_USER_NAME="hive"
ENV PIG_HOME="/opt/pig/"
ENV LD_LIBRARY_PATH="$JAVA_HOME/lib/server:$LD_LIBRARY_PATH"
ENV PATH="/home/jovyan/.local/bin/:/opt/hadoop/bin/:/opt/hive/bin/:/opt/pig/bin/:/opt/maven/bin/:$PATH"

COPY test /test

FROM sandbox-client-base AS sandbox-client-final

USER root

RUN DEBIAN_FRONTEND=noninteractive \
    apt update && \
    apt install -y vim micro && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd hive && \
    groupadd hadoop && \
    usermod -aG hive,hadoop jovyan && \
    chown -R jovyan /home/jovyan/.jupyter/ && \
    mkdir -p /home/jovyan/.local/ && \
    chown -R jovyan /home/jovyan/.local/ && \
    chmod +x /test/test.sh

USER jovyan

RUN wget -O /home/jovyan/.local/bin/jq https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-linux-amd64 && \
    chmod +x /home/jovyan/.local/bin/jq

COPY --from=ghcr.io/ca4022/csc1109-sandbox-client-apache:latest /opt/hadoop/ /opt/hadoop/
COPY --from=ghcr.io/ca4022/csc1109-sandbox-client-apache:latest /opt/hive/ /opt/hive/
COPY --from=ghcr.io/ca4022/csc1109-sandbox-client-apache:latest /opt/pig/ /opt/pig/

WORKDIR /lab/

RUN conda env config vars set -n base CLASSPATH=$(hadoop classpath --glob)
