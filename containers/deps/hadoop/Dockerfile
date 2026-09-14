ARG JAVA_VERSION=17
ARG UPSTREAM_VERSION=3.5.0

FROM docker.io/ibm-semeru-runtimes:open-${JAVA_VERSION}-jre AS jre
FROM docker.io/apache/hadoop:${UPSTREAM_VERSION}

USER root
COPY --from=jre /opt/java/openjdk /opt/java/openjdk
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV JAVA_TOOL_OPTIONS="-Xshareclasses:name=%u_csc1109_cache,cacheDir=/var/cache/javasharedresources,nonfatal -Xscmx64M"
RUN mkdir -p /var/cache/javasharedresources && chmod 1777 /var/cache/javasharedresources
USER hadoop
