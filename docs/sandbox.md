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

Before running the container, please ensure you are launching from your project folder (e.g: by
using `cd my_project_folder`) before launching the sandbox, as launching from a directory with an
extremely large file tree (e.g: `~`) can cause the sandbox to lag whenever you write to a file.

To download the container for this lab and run it, execute the following commands:

```sh
docker pull {{ page.meta.docker_image }}
docker run --rm --stop-timeout 60 --privileged --hostname sandbox -v .:/lab/ -v lab_cache:/var/containers/cache/ -p 8888:8888 -t {{ page.meta.docker_image }}
```

This command will start up the simulated cluster, build and deploy the stack, start up the
JupyterLab client, and mount your current directory as the working directory for that client.
Shortly after you see the message "Reached target **Graphical Interface**.", you can then connect
to the client via the WebUI [here](http://localhost:8888).

WARNING: Once you start this container it will remain running until you have manually stopped it,
either by sending a `SIGTERM` (by hitting ctrl+c), running `docker stop` followed by the name or
hash of the container, or stopping it via the docker desktop GUI.

## Common Issues

- My sandbox is getting stuck at `Deploying Stack` for a long time
    - The first time you deploy the sandbox with a cold cache it has to pull the containers for the
        stack from the internet, this can take a while. Even on extremely slow systems, this
        usually takes no longer than 30 minutes, so patience may be required. Once the cache is
        populated bootup should be significantly faster, taking less than a minute.
- My `beeline` shell won't connect to my hive stack
    - The hive stack can take a minute or two longer to deploy than the client, generally this
        problem will resolve within 5 minutes. If it does not, please let us know and we will help
        you debug.
- My sandbox keeps freezing
    - Usually, this is a result of the high RAM usage of the sandbox. Sadly, this is unavoidable
        when we're trying to simulate a distributed cluster on a local system. Please ensure you
        have adequate RAM and swap space allocated on your machine (see the
        [Docker Setup](./index.md#docker-setup) section of the [Home](./index.md) page for more
        info).
- My `lab_cache` volume is filling all of my disk space
    - The container images being used to build our pseudo-distributed clusters for this lab can be
        quite large and, sadly, this is an unavoidable side-effect of simulating these systems and
        their many software tools and components. While we cannot ensure your `lab_cache` remains
        small, there are steps we can take to try and manage the size of the cache as we proceed
        through the various labs. For example, if you run the command `podman system prune` inside
        a running lab container this will remove all stopped containers, and dangling or unused
        cached resources which should reduce its size. In extremely disk constrained cases it may
        be necessary to run your lab containers without mounting the cache, which should prevent
        this problem entirely but would **dramatically** increase the time it takes for each lab
        container's cluster stack to start up, usually increasing it to at least 20 minutes. For
        this reason we generally recommend to try and clear enough space to accommodate the cache,
        or if running without a cache is **completely necessary** to attempt to start your lab
        container and cluster stack at least an hour before the labs are due to begin.
- My issue isn't listed here!
    - If you're experiencing an issue that isn't included here please don't hesitate to ask us for
        assistance. We can help you figure out what the problem is, and if it comes up often enough
        we will add it to this list for future reference.
