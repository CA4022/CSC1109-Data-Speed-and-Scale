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
docker run -p 9870:9870 -it {{ page.meta.docker_test_image }}
```

## Deploying a Hadoop cluster ##

Once inside the test environment, you will be in the "/lab/" directory, which contains the
following files:

<div class="annotate" markdown>
- &nbsp; config - A folder that will contain the cluster configuration XML files (1)
- &nbsp; data - A folder containing test data files (2)
- &nbsp; docker-compose.yaml - The docker compose file configuring the hadoop stack (3)
- &nbsp; hadoop.env - An env file with the hadoop env variables for the config
- &nbsp; lab.md - A brief overview of this lab
- &nbsp; pyproject.toml - The python project config for this lab (4)
- &nbsp; uv.lock - A lockfile for the python project config (5)
</div>

1. Currently, the only file in this directory is `hadoop/core-site.xml`. This defines the config
for the current cluster, and in this lab it primarily serves as a shared attribute telling the
various nodes where they can find the NameNode.
2. The pre-packaged data file for this lab is a plaintext version of the wikipedia article for
"Word count".
3. Docker compose files allow the developer to declaratively create a collection of interconnected
containerised docker services. This allows us to quickly deploy our hadoop cluster stack in this
lab.
4. The `pyproject.toml` file is the modern, standardised way to define python project metadata in a
single file, as specified in [PEP 621](https://peps.python.org/pep-0621/)
5. Lockfiles are common in modern projects managed by package managers. They pin every package in
the project to a specific version, ensuring reproducibility.

To deploy the Hadoop cluster defined in the `docker-compose.yaml` file simply run the following
command:

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest }
ls
docker compose up -d
```

IMPORTANT: The `-d` flag tells `docker compose` to start the stack as a daemon. Otherwise, you will
be trapped in a non-interactive shell. If this happens, interrupt `docker compose` using ++ctrl+c++

DANGER: In this example we use the large, all-purpose `apache/hadoop-runner` docker image for
teaching convenience. In a production environment, it is **strongly** recommended to use minimal,
custom container images for your HPC clusters for efficiency and security.

Once your docker compose stack finishes deploying, you can view the deployed containers by running
`docker ps`. This should show you 8 active hadoop nodes in your locally deployed cluster.

- lab-namenode-1
- lab-datanode-1
- lab-datanode-2
- lab-datanode-3
- lab-datanode-3
- lab-resourcemanager-1
- lab-nodemanager-1
- lab-client-1

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

In this lab, our demonstrator cluster includes 4 DataNodes, all of which are running locally.
However, in an actual HPC setting we would generally have many DataNodes running on many different
machines.

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
s ApplicationMaster. It does not analyse jobs or delegate tasks itself; it is an executor that
simply manages containers on its local machine.

### Client ###

The client node is the node through which we will be interacting with the cluster. it includes all
the tools required to act as a Hadoop client, but does not run an actual Hadoop node. Throughout
this lab we will be connecting to this node to orchestrate what happens on our cluster.

### Summary ###

In this lab, our example cluster is a minimal one consisting of only one of each required node,
all running on a single, local machine. However, it is possible to run DataNodes and NodeManagers
on many machines, all communicating with a NameNode and ResourceManager via networks. This allows
this kind of HDFS/YARN cluster to operate on many computers in concert, efficiently coordinating
massive computations on gigantic datasets. For this reason, this kind of HDFS/YARN setup is often
deployed on supercomputers and high performance compute clusters.

## Adding a file to the HDFS Cluster ##

To begin running computations on our cluster, we must first begin my adding files to its HDFS
filesystem. To do this, we must first begin by connecting to our client node. To do this, we run
the following code:

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest }
docker compose exec -w /lab/ client bash
```

Once we are connected to the client, we can check the status if our hadoop cluster by running:

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest wrapper='docker compose exec -w /lab/ client bash -c "{command}"' }
hdfs fsck /
```

INFO: You can connect to a WebUI for your cluster at any time by opening your browser and
navigating to the URL [http://localhost:9870](http://localhost:9870). This is another way to check
your cluster status.

Once we have confirmed that the cluster is healthy, we can create a directory and put our example
file that we will use to test our code there:

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest wrapper='docker compose exec -w /lab/ client bash -c "{command}"' }
hdfs dfs -mkdir -p /lab/data/
hdfs dfs -put /lab/data/Word_count.txt hdfs://namenode/lab/data/Word_count.txt
```

Now, if we run the following command we should see that the file is present in this folder in our
HDFS filesystem:

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest wrapper='docker compose exec -w /lab/ client bash -c "{command}"' }
hdfs dfs -ls hdfs://namenode/lab/data/
```

Although this file has been added to our cluster. However, if we run the command `hdfs fsck
/lab/data/Word_count.txt -files -blocks -locations` we can see that the file currently exists on
only a single node. To spread the data across all 4 nodes, we can run the following command and
check the block locations again:

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest wrapper='docker compose exec -w /lab/ client bash -c "{command}"' }
hdfs dfs -setrep 4 /lab/data/Word_count.txt
hdfs fsck /lab/data/Word_count.txt -files -blocks -locations
```

Now, you should be able to see that the average block replication for the file is 4.0, illustrating
that the file has been replicated 4 times across the entire cluster. With the data spread across the
cluster, we can next move on to performing computations on that data through our cluster. Run
`exit` to disconnect from the client node and return to your host lab environment.

NOTE: In this case, we have replicated the complete file to each datanode manually. This is just
for demonstration purposes. In a real HPC setting, we would likely spread the file's blocks across
many nodes with a replication of greater than 1.0 but not as many replications as there are
DataNodes. The NameNode can be configured to automatically spread and balance data to facilitate
this process.

## Running Java code on a Hadoop cluster via HDFS and YARN ##

In order to perform an analysis, we will first need to write some java code that interacts with the
Hadoop server. For example, the following java source code describes a Hadoop MapReduce function
that performs a simple wordcount, on our Hadoop cluster. Create a file named `WordCount.java`
containing this source code.

TIP: Run `edit WordCount.java` to create a new empty source code file you can edit.

```java title="WordCount.java"
--8<-- "lab1/src/WordCount.java"
```

With this java source file created, the next step is to connect to the `client` node again. Once
you inside the client node you can compile `WordCount.java` on the hadoop cluster using javac and
the `jar` bytecode packager by running:

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest wrapper='docker compose exec -w /lab/ client bash -c "{command}"' }
hadoop com.sun.tools.javac.Main WordCount.java
jar cf wordcount.jar WordCount*.class
```

By running `ls`, you should now see the file `wordcount.jar` present in the working directory. This
file contains the `ApplicationMaster` object that the YARN framework will run on our cluster. To
start this computation, you can run the following command:

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest wrapper='docker compose exec -w /lab/ client bash -c "{command}"' }
hadoop jar wordcount.jar WordCount hdfs://namenode/lab/data/Word_count.txt hdfs://namenode/lab/data/output
```

Once the Hadoop cluster has finished running the `wordcount.jar` object on the cluster it will
have placed an output folder at the `./output/` directory on the HDFS cluster. To retrieve
this folder from `hdfs://namenode/lab/data/output` run the following command.

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest wrapper='docker compose exec -w /lab/ client bash -c "{command}"' }
hdfs dfs -get hdfs://namenode/lab/data/output
```

At this point, you can `exit` the client node. You should now be able to see a folder called
`./output` in your working directory. Inside that directory should be a file called `_SUCCESS` if
the operation was successful, along with a file called `part-r-000000`. You can view this file by
running:

```sh
cat output/part-r-00000
```

This should show a count of the occurrences of every unique word in the test file. If you can see
this, you have just performed your first computation on a Hadoop cluster! This is a key milestone on
any computer scientist's journey towards mastering high performance computing.

## Running code on hadoop via MRJob ##

While running cluster computations on Hadoop using java is interesting, most modern data science is
done not in java, but in python. Generally, python is the favoured language of data scientist
because it is an excellent language for writing glue code. This allows data scientists using python
to use many highly optimised libraries written in many languages to perform their computations, all
orchestrated from a higher level, more abstracted language. Hadoop is no exception to this, and
many python libraries exist that allow data scientists to leverage the HPC power of HDFS/YARN
Hadoop clusters in their python code. The library we will be using to do that in this lab will be
the `mrjob` library.

To install `mrjob`, the user can install the package using their python package manager of their
choice (often `pip` or `conda`). For reproducibility and speed, we will be using a package manager
called `uv`, and a `pyproject.toml` file describing the python environment we want to work within.

>? INFO: It is generally considered bad practice to install python packages directly to your machine
> via `pip`, as it can create dependency conflicts with system utilities. Package managers like
> `uv` can allow you to share your python environments without creating these dependency conflicts
> while also preventing the notorious "it works on my machine" problem.

To start, let us look at a basic example of a word count program in python. The code below is an
example of a straightforward, well structured wordcount program in python using a regex:

```python title="count.py"
--8<-- "lab1/src/count.py"
```

Once you have created this program, you can execute it by running:

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest }
uv run count.py ./data/Word_count.txt
```

As can be seen, this clearly worked. However, for large files it will not be particularly
performant. As a python program, it is bottlenecked by the fact that the program must be
interpreted and the program is only able to run in a single thread.

>? INFO: For those interested: more info on the performance limitations of native python code by
> researching its "Global Interpreter Lock" (GIL) feature, why it was introduced (it was originally
> a performance optimisation), and why this has become a bottleneck on python performance in our
> current HPC landscape. The ongoing "GILectomy" project in the python community serves as a great
> case study in how design decisions that were once optimisations can become performance hindrances
> over time, a valuable lesson for anyone interested in High Performance Computing!

As previously mentioned, it is possible to run this same computation on a hadoop cluster from
a python script using the `mrjob` library. This allows us to leverage the HPC capabilities of
Hadoop without needing to write all of our code in java. An equivalent python program that allows
us to run this word count via our Hadoop cluster would be the following:

```python title="mrcount.py"
--8<-- "lab1/src/mrcount.py"
```

>? NOTE: This python code makes heavy use of "type hinting". Unlike in static languages like java,
> these type hints do not create hard, statically checked boundaries on which types a function can
> accept. They are, however, considered good practice in modern high performance python code as
> they allow for: LSP usage, self documenting code, ahead of time static analysis, optimisations
> (in certain cases, e.g: when using JIT libraries such as `numba`).

Once this file has been created, we can test the `mrcount.py` script by running it on a local file:

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest }
uv run mrcount.py -r local ./data/Word_count.txt
```

Once we are confident it works, we can then reconnect to the client and run the script on the
Hadoop cluster.

```sh
docker compose exec -w /lab/ client bash
```

```sh { .test-block #ghcr.io/amileo/csc1109-lab1:latest wrapper='docker compose exec -w /lab/ client bash -c "{command}"' }
sudo pip install mrjob
python mrcount.py -r hadoop hdfs://namenode/lab/data/Word_count.txt --output-dir hdfs://namenode/lab/data/output_mrjob
```

If we then retrieve the `output_mrjob` directory similar to how we retrieved the outputs in the
previous section we can check our results and verify that this has run successfully.

QUESTION: In addition to running on files already on the HDFS cluster, it is also possible to run
python MapReduce jobs by streaming the data being processed. Would you like to learn how this
works? For anyone who wants to challenge themselves to try this, Michael Noll has shared a great
tutorial on the topic
[here](https://www.michael-noll.com/tutorials/writing-an-hadoop-mapreduce-program-in-python/).

## Bonus: run on a Cloud Platform (AWS EMR or Google DataProc) ##

We will come back to this after the Lecture on Amazon EC2 and Elastic MapReduce (EMR).
[Bonus Lab 1: Big Data Cloud](../bonus1.md)

WARNING: To run this on Elastic MapReduce you will need API keys from your AWS Console.
