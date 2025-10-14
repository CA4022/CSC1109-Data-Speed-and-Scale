FROM docker.io/apache/hadoop:3.4.1

ENV PIG_HOME="/opt/pig/"
ENV PATH="/opt/maven/bin/:$PATH"

COPY test /test

COPY --from=docker.io/apache/hive:4.0.1 /opt/hive/ /opt/hive/

USER root

RUN chmod +x /test/test.sh && \
    wget https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz && \
    tar -xf apache-maven-3.9.11-bin.tar.gz -C /opt/ && \
    mv /opt/apache-maven-3.9.11 /opt/maven && \
    rm -r apache-maven-3.9.11-bin.tar.gz && \
    mvn dependency:copy \
        -Dartifact=org.postgresql:postgresql:42.4.3:jar \
        -DoutputDirectory=/opt/hive/lib/ \
        -Dmdep.stripVersion=true && \
    wget https://downloads.apache.org/pig/pig-0.18.0/pig-0.18.0.tar.gz && \
    tar -xzf pig-0.18.0.tar.gz && \
    rm pig-0.18.0.tar.gz && \
    mv pig-0.18.0 $PIG_HOME && \
    rm $PIG_HOME/conf/pig.properties

COPY pig.properties $PIG_HOME/conf/pig.properties

USER hadoop
