ARG HADOOP_VERSION=3.4.1
FROM docker.io/apache/hadoop:${HADOOP_VERSION}

USER root
COPY --from=docker.io/ibm-semeru-runtimes:open-17-jre /opt/java/openjdk /opt/java/openjdk
ENV JAVA_TOOL_OPTIONS="-Xshareclasses:name=csc1109_cache,cacheDir=/var/cache/javasharedresources -Xscmx64M"
RUN mkdir -p /var/cache/javasharedresources && chmod 1777 /var/cache/javasharedresources
USER hadoop
