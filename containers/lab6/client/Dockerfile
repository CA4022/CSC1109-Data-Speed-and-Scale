FROM quay.io/jupyter/all-spark-notebook:java-17.0.15

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop
ENV HIVE_HOME=/opt/hive
ENV HIVE_USER_NAME=hive
ENV PIG_HOME=/opt/pig/
ENV LD_LIBRARY_PATH=$JAVA_HOME/lib/server:$LD_LIBRARY_PATH
ENV PATH=/home/jovyan/.local/bin/:/opt/hadoop/bin/:/opt/hive/bin/:/opt/pig/bin/:${PATH}

COPY --from=docker.io/apache/hive:4.0.1 /opt/hive/ /opt/hive/

COPY jupyter_server_config.py /home/jovyan/.jupyter/jupyter_server_config.py
COPY user-settings /home/jovyan/.jupyter/lab/user-settings
COPY test /test

USER root

COPY ./spark-defaults.conf ${SPARK_CONF_DIR}/spark-defaults.conf
RUN echo "3.10.*" > /opt/conda/conda-meta/pinned && \
    chown -R jovyan /home/jovyan/.jupyter/ && \
    mkdir -p /home/jovyan/.local/ && \
    chown -R jovyan /home/jovyan/.local/ && \
    chmod +x /test/test.sh && \
    groupadd hive && \
    groupadd hadoop && \
    useradd -g hive -g hadoop -k /root/ -m jovyan && \
    wget https://downloads.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz && \
    tar -xzf pig-0.17.0.tar.gz && \
    rm pig-0.17.0.tar.gz && \
    mv pig-0.17.0 $PIG_HOME && \
    echo "exectype=spark" >> $PIG_HOME/conf/pig.properties

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
    rm rapaio-jupyter-kernel-2.2.0.jar && \
    wget -O /home/jovyan/.local/bin/jq https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-linux-amd64 && \
    chmod +x /home/jovyan/.local/bin/jq


COPY java_logo.png /home/jovyan/.local/share/jupyter/kernels/rapaio-jupyter-kernel/logo-64x64.png
COPY --from=docker.io/apache/hadoop:3.4.1 /opt/hadoop/ /opt/hadoop/

RUN conda env config vars set -n base CLASSPATH=$(hadoop classpath --glob)

