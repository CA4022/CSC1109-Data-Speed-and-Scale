FROM ghcr.io/ca4022/csc1109-base-root:latest AS student-environment

ARG BASE_GCC_VERSION
ARG BASE_BASH_VERSION
ARG BASE_GIT_VERSION

RUN for i in 1 2 3 4 5; do zypper --non-interactive install --no-recommends systemd && break || { [ $i -eq 5 ] && exit 1 || sleep 15; }; done && \
    for i in 1 2 3 4 5; do zypper --non-interactive install \
        iptables \
        python313 \
        wget \
        man \
        maven \
        java-17-openj9-devel \
        curl \
        update-alternatives && break || { [ $i -eq 5 ] && exit 1 || sleep 15; }; done && \
    rpm -qa 'python311*' | xargs -r zypper rm --clean-deps && \
    mkdir -p /var/cache/javasharedresources && chmod 1777 /var/cache/javasharedresources && \
    update-alternatives --set java /usr/lib64/jvm/jre-17-openj9/bin/java && \
    zypper clean --all && \
    curl -fL https://downloads.lightbend.com/scala/2.13.12/scala-2.13.12.tgz | tar xz -C /opt && \
    ln -s /opt/scala-2.13.12/bin/scala /usr/bin/scala && \
    ln -s /opt/scala-2.13.12/bin/scalac /usr/bin/scalac

COPY --from=ghcr.io/astral-sh/uv:0.9.22 /uv /uvx /bin/

# Assembly stage: copy over application-specific code, tests, and entrypoint.
# These files are expected to change most frequently.
FROM student-environment AS final

# Create working directory and a directory needed to suppress emacs warnings.
RUN mkdir /lab
WORKDIR /lab

# Collect container tests
RUN mv /test/ /test-base/
COPY ./test/ /test/
RUN mv /test-base/ /test/base/ && chmod -R +x /test/

# Set env variables
ENV JAVA_HOME=/usr/lib64/jvm/java-17-openj9-17
ENV PATH="${JAVA_HOME}/bin:/opt/hdfs/bin:/opt/hadoop/bin:/opt/hive/bin:/opt/pig/bin:/apache-storm/bin:/apache-zookeeper-3.9.3-bin/bin:/opt/spark/bin:${PATH}"
ENV JAVA_TOOL_OPTIONS="-Xshareclasses:name=csc1109_cache,cacheDir=/var/cache/javasharedresources -Xscmx64M"

# Copy lab specific files and set entrypoint running
COPY ./lab/ /lab/
COPY ./bin/ /bin/
COPY entrypoint.sh /entrypoint.sh
COPY entrypoint.py /entrypoint.py
COPY entrypoint.service /etc/systemd/system/entrypoint.service

RUN chmod +x /entrypoint.sh && \
    systemctl mask \
        getty@.service \
        serial-getty@.service \
        getty.target \
        proc-sys-fs-binfmt_misc.automount \
        sys-kernel-debug.mount \
        sys-kernel-tracing.mount \
        sys-kernel-config.mount && \
    systemctl enable entrypoint.service && \
    chmod +x /entrypoint.py

STOPSIGNAL SIGRTMIN+3

CMD ["/entrypoint.sh"]
