---
title: "The CSC1109 Sandbox Environment 󱐕&nbsp;󰹥&nbsp;"
docker_image: ghcr.io/ca4022/csc1109-sandbox:latest
---

{{ "# " ~ page.meta.title ~ " #" }}

Throughoute the duration of this course you will have assignments, tasks, and perhaps even analyses
you would like to try by yourself. To make it as easy as possible for you to explore of the
technologies you are learning about, this sandbox will provide you with a single environment
integrating all of these technologies in a distributed stack. This stack provides:

- A Jupyter notebook client
- Hadoop
- Spark
- Hive
- Pig

To download the container for this lab and run it, execute the following commands:

```sh
docker pull {{ page.meta.docker_image }}
docker run --rm --privileged --hostname sandbox -v .:/lab/ -p 8888:8888 -t {{ page.meta.docker_image }}
```

This command will start up the simulated cluster, build and deploy the stack, start up the
[JupyterLab client](http://0.0.0.0:8888), and mount your current directory as the working directory
for the client.
