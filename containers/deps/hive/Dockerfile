ARG UPSTREAM_VERSION=4.2.1
FROM docker.io/apache/hive:${UPSTREAM_VERSION}

USER root
COPY --from=docker.io/ibm-semeru-runtimes:open-21-jre /opt/java/openjdk /opt/java/openjdk
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV JAVA_TOOL_OPTIONS="-Xshareclasses:name=%u_csc1109_cache,cacheDir=/var/cache/javasharedresources,nonfatal -Xscmx64M"
RUN mkdir -p /var/cache/javasharedresources && chmod 1777 /var/cache/javasharedresources
USER hive
