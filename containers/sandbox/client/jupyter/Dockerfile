FROM quay.io/jupyter/all-spark-notebook:spark-4.0.1

ENV PATH="/home/jovyan/.local/bin/:$PATH"
ENV JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
ENV SPARK_CONF_DIR="/opt/spark/conf"

COPY jupyter_server_config.py /home/jovyan/.jupyter/jupyter_server_config.py
COPY user-settings /home/jovyan/.jupyter/lab/user-settings
COPY ./spark-defaults.conf $SPARK_CONF_DIR/spark-defaults.conf
COPY ./csc1109-launcher/ /home/jovyan/.local/share/csc1109-launcher/
COPY test /test

USER root

RUN chmod +x /test/test.sh && \
    chown -R jovyan /home/jovyan/.local/ && \
    chown -R jovyan /home/jovyan/.jupyter/

USER jovyan

WORKDIR /home/jovyan/.local/share/csc1109-launcher/

RUN mamba update -n base --all --yes && \
    mamba clean --all --yes && \
    mamba install -n base -y \
        fsspec \
        hatch \
        ipywidgets \
        jupyter-lsp \
        jupyterlab-day \
        jupyterlab-lsp \
        jupyterlab-night \
        jupyterlab-unfold \
        jupyterlab-variableinspector \
        jupyterlab_widgets \
        mamba_gator \
        pyarrow \
        python-build \
        pyright \
        twine && \
    mamba run -n base python -m build && \
    mamba run -n base python -m pip install ./dist/*.whl && \
    mamba remove -n base python-build twine hatch && \
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

WORKDIR /home/jovyan

