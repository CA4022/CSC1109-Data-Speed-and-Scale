FROM ghcr.io/amileo/csc1109-base:latest AS lab3-client

COPY --from=docker.io/apache/hadoop:3.4.1 /opt/hadoop/ /opt/hadoop/
RUN wget https://downloads.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz && \
    tar -xzf pig-0.17.0.tar.gz && \
    mv pig-0.17.0 /opt/pig && \
    useradd -m hadoop
ENV PATH=/opt/pig/bin:$PATH
ENV PIG_HOME=/opt/hadoop
ENV PIG_HOME=/opt/pig
USER hadoop
CMD [ "sleep", "infinity" ]
