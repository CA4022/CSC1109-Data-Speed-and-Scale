FROM quay.io/jupyter/all-spark-notebook:2025-07-28

ENV PATH=/home/jovyan/.local/bin/:${PATH}

RUN echo "3.10.*" > /opt/conda/conda-meta/pinned && \
    conda install -n base -y \
        python=3.10 \
        ipywidgets \
        jupyter-lsp \
        jupyterlab-day \
        jupyterlab-lsp \
        jupyterlab-night \
        jupyterlab-plotly-extension \
        jupyterlab-unfold \
        jupyterlab-variableinspector \
        jupyterlab_widgets \
        pyright && \
    wget -q https://git.io/coursier-cli && \
    mkdir -p /home/jovyan/.local/bin/ && \
    mv coursier-cli /home/jovyan/.local/bin/coursier && \
    chmod +x /home/jovyan/.local/bin/coursier && \
    coursier bootstrap --standalone almond:0.14.1 --scala 2.13 --output /home/jovyan/.local/bin/almond && \
    almond --install && \
    coursier bootstrap org.scalameta:metals_2.13:1.6.0 -o metals -f && \
    mv metals /home/jovyan/.local/bin/metals && \
    wget -q https://github.com/padreati/rapaio-jupyter-kernel/releases/download/2.2.0/rapaio-jupyter-kernel-2.2.0.jar && \
    java -jar ./rapaio-jupyter-kernel-2.2.0.jar -i -auto && \
    rm rapaio-jupyter-kernel-2.2.0.jar

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV LD_LIBRARY_PATH=$JAVA_HOME/lib/server:$LD_LIBRARY_PATH

COPY --from=docker.io/apache/hadoop:3.4.1 /opt/hadoop/ /opt/hadoop/
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_USER_NAME=hadoop
ENV PATH=/opt/hadoop/bin/:${PATH}

COPY java_logo.png /home/jovyan/.local/share/jupyter/kernels/rapaio-jupyter-kernel/logo-64x64.png

COPY jupyter_server_config.py /home/jovyan/.jupyter/jupyter_server_config.py
COPY user-settings /home/jovyan/.jupyter/lab/user-settings
USER root
COPY ./spark-defaults.conf ${SPARK_CONF_DIR}/spark-defaults.conf
RUN chown -R jovyan /home/jovyan/.jupyter/ && \
    mkdir -p /test/ && \
    echo "echo 'No tests implemented!'" >> /test/test.sh && \
    chmod +x /test/test.sh
USER jovyan
