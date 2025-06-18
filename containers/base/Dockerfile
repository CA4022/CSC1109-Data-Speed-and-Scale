FROM ghcr.io/amileo/csc1109-base-root:latest AS student-environment

ARG BASE_GCC_VERSION
ARG BASE_BASH_VERSION
ARG BASE_GIT_VERSION
ARG BASE_DOCKER_VERSION
ARG BASE_COMPOSE_VERSION

RUN zypper --non-interactive refresh && \
    zypper --non-interactive install \
        bash-${BASE_BASH_VERSION} \
        gcc-${BASE_GCC_VERSION} \
        git-${BASE_GIT_VERSION} \
        docker-${BASE_DOCKER_VERSION} \
        docker-compose-${BASE_COMPOSE_VERSION} \
        python312 \
        wget && \
    zypper clean --all

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

# Copy lab specific files and set entrypoint running
COPY ./lab/ /lab/
COPY entrypoint.py /entrypoint.py
RUN chmod +x /entrypoint.py
CMD ["/entrypoint.py"]
