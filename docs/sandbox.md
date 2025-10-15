---
title: "The CSC1109 Sandbox Environment 󱐕&nbsp;󰹥&nbsp;"
docker_image: ghcr.io/ca4022/csc1109-sandbox:latest
---

{{ "# " ~ page.meta.title ~ " #" }}

Throughout the duration of this course you will have assignments, tasks, and perhaps even analyses
you would like to try by yourself. To make it as easy as possible for you to explore the
technologies you are learning about this sandbox will provide you with an environment integrating
all of these technologies in a single, modern, (simulated) distributed stack. This stack closely
resembles the kind of stack you could expect to find on a modern cluster in a real computational
research environment, providing:

- A Jupyter notebook client
- A Hadoop cluster
- A Spark cluster
- A Hive cluster
- A Pig client

To download the container for this lab and run it, execute the following commands:

```sh
docker pull {{ page.meta.docker_image }}
docker run --rm --privileged --hostname sandbox -v .:/lab/ -p 8888:8888 -t {{ page.meta.docker_image }}
```

This command will start up the simulated cluster, build and deploy the stack, start up the
JupyterLab client, and mount your current directory as the working directory for that client. Once
you see the message "Finished **Deploy Cluster Stack**.", you can then connect to the client via a
WebUI [here](http://0.0.0.0:8888).

WARNING: Once you start this container it will remain running until you have manually stopped it,
either by sending a `SIGTERM` (by hitting ctrl+c) or running `docker stop` followed by the name or
hash of the container.
