ARG UPSTREAM_VERSION=3.9.5-jre-17
FROM docker.io/library/zookeeper:${UPSTREAM_VERSION}

COPY --from=docker.io/ibm-semeru-runtimes:open-17-jre /opt/java/openjdk /opt/java/openjdk
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV JAVA_TOOL_OPTIONS="-Xshareclasses:name=csc1109_cache,cacheDir=/var/cache/javasharedresources -Xscmx64M"
RUN mkdir -p /var/cache/javasharedresources && chmod 1777 /var/cache/javasharedresources
