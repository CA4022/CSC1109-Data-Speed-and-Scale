FROM ghcr.io/amileo/csc1109-base:latest AS lab1-environment

COPY --from=docker.io/apache/hadoop:3.4.1 /opt/hadoop/ /opt/hadoop/
COPY ./lab/ /lab/
RUN chown -R 1000 /lab/ && uv sync
