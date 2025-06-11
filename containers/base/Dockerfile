ARG BASE_OPENSUSE_VERSION
FROM docker.io/opensuse/leap:${BASE_OPENSUSE_VERSION}

ARG HOSTNAME="base"
ARG BASE_OPENSUSE_VERSION
ARG BASE_GCC_VERSION
ARG BASE_BASH_VERSION
ARG BASE_GIT_VERSION
ARG BASE_DOCKER_VERSION
ARG BASE_COMPOSE_VERSION

# Install core packages
RUN zypper --non-interactive addrepo "https://download.opensuse.org/repositories/Virtualization:containers/${BASE_OPENSUSE_VERSION}/Virtualization:containers.repo"
RUN zypper --non-interactive --gpg-auto-import-keys refresh
RUN zypper --non-interactive install bash-${BASE_BASH_VERSION} gcc-${BASE_GCC_VERSION} git-${BASE_GIT_VERSION} docker-${BASE_DOCKER_VERSION} docker-compose-${BASE_COMPOSE_VERSION}

# Set working directory
RUN mkdir /lab
WORKDIR /lab

# Prepare entrypoint to initialise environment
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Run interactuve shell
CMD ["bash"]
