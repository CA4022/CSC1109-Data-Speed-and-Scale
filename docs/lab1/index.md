---
title: "Lab 1: Hadoop MapReduce"
docker_test_image: ghcr.io/amileo/csc1109-lab1:latest
test_volumes:
- host_path: ./docs/lab1/src/
  container_path: /lab/src/
  mode: ro
init_commands:
  - cp -r /lab/src/* /lab/
---

{{ "# " ~ page.meta.title ~ " #" }}

This lab will teach you how to configure and deploy a containerised hadoop cluster, and how to use
it to perform computations. As an introduction to programming a hadoop cluster we will start by
writing a basic wordcount program, as illustrated in Part 2 of the lecture slides.

To download the container for this lab, run the following command:

```sh
docker run -it {{ page.meta.docker_test_image }}
```

## Deploying a Hadoop cluster ##

Once inside the test environment, you will be in the "/lab/" directory, which contains the
following files:

- &nbsp; data - A folder containing test data files
- &nbsp; docker-compose.yaml - The docker compose file configuring the hadoop stack
- &nbsp; hadoop.env - An env file with the hadoop env variables for the config
- &nbsp; lab.md - A brief overview of this lab
- &nbsp; pyproject.toml - The python project config for this lab
- &nbsp; uv.lock - A lockfile for the python project config

To deploy the Hadoop cluster defined in the `docker-compose.yaml` file simply run the following
command:

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest }
ls
docker compose up -d
```

IMPORTANT: The `-d` flag tells `docker compose` to start the stack as a daemon. Otherwise, you will
be trapped in a non-interactive shell. If this happens, interrupt `docker compose` using `ctrl+c`

Once your docker compose stack finishes deploying, you can view the deployed containers by running
`docker ps`. This should show you 4 active hadoop nodes in your locally deployed cluster.

- lab-namenode-1
- lab-datanode-1
- lab-resourcemanager-1
- lab-nodemanager-1

### NameNode ###

The NameNode serves as the master server for the HDFS cluster. Think of it as the "table of
contents" for our distributed file system. It does not store the actual data files but instead
holds all the crucial filesystem metadata. This includes the filesystem directory tree, file
permissions, and, most importantly, the locations of all the data blocks that make up the files.

Client applications interact with the NameNode first to request metadata. For example, they may
request to find out which DataNodes hold the blocks for a specific file. If a client requests to
change data, the NameNode controls permission and receives notification of the changes from the
client. Periodically, the DataNodes will report their block status back to the NameNode and it will
verify that against its own recorded metadata. In this way, it acts as a reliable single source of
truth for the file system's structure.

### DataNodes ###

The DataNodes are the workhorses of the HDFS cluster that actually store the data. Each machine in
the cluster runs a DataNode that is responsible for its share of the cluster's storage. These nodes
only store data, they do not perform any computations on it.

When a client application needs to write a file, the NameNode tells it which DataNodes to send the
data blocks to. The client then writes the blocks directly to those DataNodes. Similarly, when a
client wants to read a file, it first gets the block locations from the NameNode and then reads the
file's contents directly from the DataNodes. The DataNodes do not send data back through the
NameNode. This direct access is key to HDFS's high throughput. DataNodes are also responsible for
replicating their data blocks to other DataNodes to ensure fault tolerance.

### ResourceManager ###

The ResourceManager is the master node of the YARN framework, which manages the cluster's
computational resources (CPU and RAM). While HDFS manages the distributed data, YARN manages
distributed computation.

The ResourceManager has a global view of all available resources in the cluster. Its primary job
is to allocate these resources to applications. It does this by negotiating with a per
application ApplicationMaster and granting it permission to use "containers" on specific nodes.
It is purely a resource allocator and does not run any application tasks itself.

### NodeManagers ###

The NodeManager is a YARN agent that runs on each machine in the cluster, alongside the DataNode.
Its job is to manage the resources of that single machine.

When the ResourceManager allocates a container on a machine, it is the NodeManager on that
machine that physically launches the container and monitors its resource usage (CPU/RAM). The
NodeManager takes its direct orders on what code to run inside the container from the application
s ApplicationMaster. It does not analyze jobs or delegate tasks itself; it is an executor that
simply manages containers on its local machine.

### Summary ###

In this lab, our example cluster is a minimal one consisting of only one of each required node,
all running on a single, local machine. However, it is possible to run DataNodes and NodeManagers
on many machines, all communicating with a NameNode and ResourceManager via networks. This allows
this kind of HDFS/YARN cluster to operate on many computers in concert, efficiently coordinating
massive computations on gigantic datasets. For this reason, this kind of HDFS/YARN setup is often
deployed on supercomputers and high performance compute clusters.

## Running Java code on a Hadoop cluster via HDFS FS ##

In order to perform an analysis, we will first need to write some java code that interacts with the
Hadoop server. For example, the following java source code describes a Hadoop MapReduce function
that performs a simple wordcount, with the workload on a cluster.

```java title="WordCount.java"

--8<-- "./lab1/src/WordCount.java"

```

```sh
docker compose exec resourcemanager bash
```

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest wrapper='docker compose exec -w /lab/ resourcemanager bash -c "{command}"' }
cd /lab/
hadoop com.sun.tools.javac.Main WordCount.java
jar cf wordcount.jar WordCount*.class
hdfs dfs -mkdir -p /lab/data/
hdfs dfs -put /lab/data/Word_count.txt hdfs://namenode/lab/data/Word_count.txt
hdfs dfs -ls hdfs://namenode/lab/data/
hadoop jar wordcount.jar WordCount hdfs://namenode/lab/data/Word_count.txt hdfs://namenode/lab/data/output
hdfs dfs -get hdfs://namenode/lab/data/output
```

at this point: ./output should contain the file "_SUCCESS" if the operation was successful

```sh
cat output/part-r-00000
```

## Running code on hadoop via MRJob ##

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest }
uv run count.py ./data/Word_count.txt
uv run mrcount.py ./data/Word_count.txt
uv run mrcount.py -r local ./data/Word_count.txt
```

```sh
docker compose exec resourcemanager bash
```

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest wrapper='docker compose exec -w /lab/ resourcemanager bash -c "{command}"' }
cd /lab/
sudo pip install mrjob
python mrcount.py -r hadoop hdfs://namenode/lab/data/Word_count.txt --output-dir hdfs://namenode/lab/data/output_mrjob
```
