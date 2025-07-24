FROM ghcr.io/amileo/csc1109-base

COPY --from=docker.io/library/spark:4.0.0-scala2.13-java17-python3-ubuntu /opt/spark/ /opt/spark/

RUN useradd -m spark && \
    mkdir /home/spark/ && \
    chown -R spark /home/spark/

USER spark
