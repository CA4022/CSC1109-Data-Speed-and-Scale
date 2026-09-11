ARG UPSTREAM_VERSION=4.1.3-scala2.13-java17-python3-ubuntu
FROM docker.io/apache/spark:${UPSTREAM_VERSION}

USER root
COPY --from=docker.io/ibm-semeru-runtimes:open-17-jre /opt/java/openjdk /opt/java/openjdk
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV JAVA_TOOL_OPTIONS="-Xshareclasses:name=%u_csc1109_cache,cacheDir=/var/cache/javasharedresources,nonfatal -Xscmx64M"
RUN mkdir -p /var/cache/javasharedresources && chmod 1777 /var/cache/javasharedresources && \
    apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update && apt-get install -y python3.13 python3.13-venv && \
    ln -sf /usr/bin/python3.13 /usr/bin/python3 && \
    ln -sf /usr/bin/python3.13 /usr/bin/python
USER spark
ENV PYSPARK_PYTHON=python3.13
ENV PYSPARK_DRIVER_PYTHON=python3.13
