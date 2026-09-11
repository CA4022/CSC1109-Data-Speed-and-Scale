ARG UPSTREAM_VERSION=4.1.3-scala2.13-java17-python3-ubuntu
FROM docker.io/apache/spark:${UPSTREAM_VERSION}

USER root
COPY --from=docker.io/ibm-semeru-runtimes:open-17-jre /opt/java/openjdk /opt/java/openjdk
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV JAVA_TOOL_OPTIONS="-Xshareclasses:name=csc1109_cache,cacheDir=/var/cache/javasharedresources -Xscmx64M"
RUN mkdir -p /var/cache/javasharedresources && chmod 1777 /var/cache/javasharedresources
USER spark
