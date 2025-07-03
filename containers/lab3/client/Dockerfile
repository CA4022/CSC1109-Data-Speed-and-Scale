FROM ghcr.io/amileo/csc1109-base:latest AS lab3-client

ENV PATH=/opt/hdfs/bin:$PATH
ENV HADOOP_HOME=/opt/pig

RUN wget https://downloads.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz && \
    tar -xzf pig-0.17.0.tar.gz && \
    mv pig-0.17.0 /opt/pig

ENV PATH=/opt/pig/bin:$PATH
ENV PIG_HOME=/opt/pig

CMD [ "sleep", "infinity" ]
