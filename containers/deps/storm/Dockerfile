ARG UPSTREAM_VERSION=2.8.9-jre17
FROM docker.io/library/storm:${UPSTREAM_VERSION}

COPY --from=docker.io/ibm-semeru-runtimes:open-17-jre /opt/java/openjdk /opt/java/openjdk
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV JAVA_TOOL_OPTIONS="-Xshareclasses:name=%u_csc1109_cache,cacheDir=/var/cache/javasharedresources,nonfatal -Xscmx64M"
RUN mkdir -p /var/cache/javasharedresources && chmod 1777 /var/cache/javasharedresources
