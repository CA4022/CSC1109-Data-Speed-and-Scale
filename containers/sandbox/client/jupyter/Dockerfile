FROM quay.io/jupyter/all-spark-notebook:java-17.0.15

ENV PATH="/home/jovyan/.local/bin/:$PATH"
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
ENV SPARK_CONF_DIR="/opt/spark/conf"

COPY jupyter_server_config.py /home/jovyan/.jupyter/jupyter_server_config.py
COPY user-settings /home/jovyan/.jupyter/lab/user-settings
COPY ./spark-defaults.conf $SPARK_CONF_DIR/spark-defaults.conf
COPY test /test

USER root

RUN chmod +x /test/test.sh && \
    echo "3.10.*" > /opt/conda/conda-meta/pinned

USER jovyan

RUN mamba update -n base --all --yes && \
    mamba install -n base -y \
        python=3.10 \
        fsspec \
        ipywidgets \
        jupyter-lsp \
        jupyterlab-day \
        jupyterlab-lsp \
        jupyterlab-night \
        jupyterlab-plotly-extension \
        jupyterlab-unfold \
        jupyterlab-variableinspector \
        jupyterlab_widgets \
        pyarrow \
        pyright && \
    mamba clean --all --yes && \
    wget -q https://git.io/coursier-cli && \
    mkdir -p /home/jovyan/.local/bin/ && \
    mv coursier-cli /home/jovyan/.local/bin/coursier && \
    chmod +x /home/jovyan/.local/bin/coursier && \
    coursier bootstrap --standalone almond:0.14.1 --jvm-dir $JAVA_HOME --scala 2.13 --output /home/jovyan/.local/bin/almond && \
    almond --env JAVA_HOME=$JAVA_HOME --install && \
    # coursier bootstrap org.scalameta:metals_2.13:1.6.0 -o metals -f && \
    # mv metals /home/jovyan/.local/bin/metals && \
    wget -q https://github.com/padreati/rapaio-jupyter-kernel/releases/download/2.2.0/rapaio-jupyter-kernel-2.2.0.jar && \
    java -jar ./rapaio-jupyter-kernel-2.2.0.jar -i -auto && \
    rm rapaio-jupyter-kernel-2.2.0.jar

COPY java_logo.png /home/jovyan/.local/share/jupyter/kernels/rapaio-jupyter-kernel/logo-64x64.png
