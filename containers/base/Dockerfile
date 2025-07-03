FROM ghcr.io/amileo/csc1109-base-root:latest AS student-environment

ARG BASE_GCC_VERSION
ARG BASE_BASH_VERSION
ARG BASE_GIT_VERSION
ARG BASE_DOCKER_VERSION
ARG BASE_COMPOSE_VERSION

RUN zypper --non-interactive refresh && \
    zypper --non-interactive install \
        docker-${BASE_DOCKER_VERSION} \
        docker-compose-${BASE_COMPOSE_VERSION} \
        python312 \
        wget \
        maven \
        java-11-openjdk \
        scala && \
    zypper clean --all

COPY --from=ghcr.io/astral-sh/uv:0.7.13 /uv /uvx /bin/

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
ENV JAVA_HOME=/usr/lib64/jvm/java-11-openjdk-11

# Copy lab specific files and set entrypoint running
COPY ./lab/ /lab/
COPY ./bin/ /bin/
COPY entrypoint.py /entrypoint.py
RUN chmod +x /entrypoint.py
CMD ["dotenv", "/entrypoint.py"]
