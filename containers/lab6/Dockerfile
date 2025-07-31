FROM ghcr.io/amileo/csc1109-dind-minimal:latest AS lab6-environment

COPY ./lab/ /lab/
RUN chmod -R 777 /lab/
ENTRYPOINT ["docker", "compose", "up", "-d"]
