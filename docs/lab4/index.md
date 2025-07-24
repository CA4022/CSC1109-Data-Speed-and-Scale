---
title: "Lab 4: Storm"
docker_test_image: ghcr.io/amileo/csc1109-lab4:latest
test_volumes:
- host_path: ./docs/lab4/src/
  container_path: /lab/src/main/com/csc1104/lab/
  mode: ro
init_commands:
  - mkdir /lab/src/main/resources/
  - cp /lab/src/main/java/com/csc1104/lab/splitline.py /lab/src/main/resources/splitline.py
---

{{ "# " ~ page.meta.title ~ " #" }}

This lab asks you to try and set up a simple Apache Storm topology.

To download the container for this lab, run the following command:

```sh
docker run --privileged --hostname lab4 -p 8000:8080 -it {{ page.meta.docker_test_image }}
```

Once the container has downloaded and initialised, deploy your docker compose stack. You can
continue to read on while the stack deploys.

# The Basics: Storm and Maven #

Once your storm cluster stack has deployed you will see that it is comprised of 3 types of nodes:

- Supervisor nodes: these nodes are the main computational workhorses, running and managing
individual tasks.
- A nimbus node: these nodes are the scheduler nodes that manage the delegation and coordination of
tasks across the supervisor nodes.
- A zookeeper node: this node coordinates the cluster state between the nimbus and supervisor
nodes. By keeping all the cluster state in the zookeeper the nimbus and supervisor nodes can be
kept stateless, which is essential to the fault-tolerance and performance of storm clusters.

And, of course, a separate client node on the same network that we can use as an ingress point into
our cluster.

This project will be managed by a tool called maven. Similar to the `uv` package manager we used
[back in Lab 1](../lab1/index.md#running-code-on-hadoop-via-mrjob), maven is a **project package
manager but for java**. We will be using this as it allows us to coordinate and manage the pulling
of various libraries, including specialised storm classes.

>? INFO: Package managers like Maven can seem like an inconvenience at first, but as you work on
> more and more bigger and bigger projects they become indispensable. In the past, programmers had
> to manually manage their own project dependencies, often leading to a frustrating state of
> conflicting library versions and hard-to-diagnose errors known as "dependency hell". Nowadays,
> most modern programming languages include a package manager or similar project management tools.
> Other notable examples you may encounter in the wild but won't in these labs include javascript's
> `npm`, rust's `cargo`, and `nuget` for the .NET ecosystem.

Apache storm works by running self-contained, (usually) stateless classes called "bolts". These
bolts can be written in almost any programming language, but must be wrapped in a java interface
so that they can be handled the same as any other bolt. This allows for many bolts to be quickly
and easily combined into distributed pipelines of computational operations known as **"topologies"**.
A Storm topology is a directed, acyclic computation graph featuring two primary components:

- Spouts: These are the sources of data streams in the topology. A spout's role is to read data from
an external source like a message queue (e.g., Kafka), a Twitter feed, or a file and emit it as a
stream of **tuples**. Tuples are the fundamental data structure in Storm.

- Bolts: As previously discussed, these are the processing units of the topology. Each bolt receives
tuples from spouts or other bolts, performs a specific computation (such as filtering, aggregation,
or database interaction), and can optionally emit new tuples to be processed by other bolts
downstream.

Data streamed from the spouts is passed to self-contained bolts, which then pass their results to
other bolts, causing data to propagate through the graph in a dataflow. These dataflows across a
graph of self-contained, stateless nodes are fundamentally easier to reason about than other
distributed structures (e.g: MapReduce), allowing for easier optimisation and maintenance. This
makes apache storm a powerful tool for creating very large, highly concurrent data processing
topologies.

# What is a Topology? #

`Bolts` and `Spouts` in Storm are organised into a composite class called a `Topology`.
A `Topology` is a "Distributed Acyclic Graph" (DAG) that defines the complete logic of a real-time
application. In this graph:

- The nodes are the `Spouts` and `Bolts`.
- The edges are the data streams of `Tuples` that flow between them.

The term "Directed" here means that data flows in a specific, predefined direction — being pushed
from `Spouts` to `Bolts`, and then from bolt to bolt. The term "Acyclic" is crucial; it means the
graph has no cycles or loops. This is a fundamental constraint that guarantees a tuple will not be
passed around in an infinite loop and that processing for any given piece of data will eventually
end. This well-defined, loop-free structure allows the Storm scheduler to effectively partition the
graph and distribute its components across a cluster of machines, enabling massive parallelism and
fault-tolerance.

# Your first Storm Topology - Wordcount #

As we did with the other HPC technologies we've learned so far, lets start by creating a storm
topology for a simple wordcount task. To do this, we first need to set up our project folder and
write some source code for our topology. If you take a look at the `pom.xml` file (maven's project
config file) you will see that we have preconfigured the project to include the dependency
`org.apache.storm`, which provides us the building blocks we will use to construct our topology.
You will also see that we have the `groupId` `com.csc1104.lab`. This is important to note, as maven
projects have strict requirements for project folder structure. These requirements say that:

- Source code must be in a `src` directory
- Runtime code must go in the `main` subdirectory
- Java code must be placed in a `java` subdirectory, to keep it separate from code in other
languages
- Each attribute of the `groupId` must have its own nested directory containing its sub-attributes

So, to satisfy this, we need to create the directory `src/main/java/com/csc1104/lab/` which will contain
our source code. Create this directory and navigate to it. In the following sections, we will
explain the process of making a storm topology and as we proceed you should add the source code
files shown to this directory.

## Creating Bolts  ##

To start building our topology, lets create some bolts. Since the idea of bolts is that they should
be small, self contained, stateless computational units we should start by creating bolts for the
key steps of our task. The two key steps for our word counting process are:

1. Breaking lines from the text files up into words
2. Counting the instances of each word
3. Aggregating the results and dumping them to a file

Since we know what output we want and we expect that the performance bottlenecks here will be steps
2(1) and 3(2), we should design the data pipeline in the upstream direction.
{ .annotate }

1. String matching is generally quite slow
2. IO writes to disk are generally much slower than reads

### ReportBolt ###

To aggregate the results of the word count and output them, we first need to think about what type
of `Tuple`(1) we expect this bolt to receive. For simplicity, we want each `Tuple` to be in the
form of just a word and a count. This allows us to receive tuples in any order and still handle
them correctly. Once these counts have been aggregated, we then need to output the results
somewhere. In the code below, this is handled using a common pattern for this kind of distributed
system called a "tick packet". Once a tick packet is received (in this case every 2 seconds) the
bolt will overwrite the specified output file with a dump of the current word counts.
{ .annotate }

1. In a storm topology, all packets passed between bolts are in the form of a `Tuple`. A `Tuple` is
an ordered, immutable collection of named fields (like a read-only Map<String, Object> with fixed
keys and order) optimized for efficient network transfer and parallel processing.

```java title="src/main/java/com/csc1104/lab/ReportBolt.java"
--8<-- "lab4/src/ReportBolt.java"
```

### WordCountBolt ###

Because this step is expected to be performance bottleneck, we need to design the bolt for
counting instances of each word to be small, efficient, and performant. For this reason,
lets build a small bolt class in pure java that makes use of a `HashMap` class for word counting.
Our first intuition might be to design this bolt so that it sends each word immediately when
counted, however if we did this we would always get a count of 1, entirely defeating the purpose
of distributed counting! Instead, we should batch the counts at this step to begin reducing the
amount of packet traffic before we send these on to the `ReportBolt`. Here, we have set the
batch size to 64, which should give us packets averaging about 2kb (a good size for a realtime
processing storm topology). Finally, what happens if we only get <64 tuples at the end of our file?
To avoid this problem, we will again use the tick packet pattern again to tell the `WordCountBolt`
to send its current batch downstream if it doesn't receive any new tuples for 1 second.

```java title="src/main/java/com/csc1104/lab/WordCountBolt.java"
--8<-- "lab4/src/WordCountBolt.java"
```

### SplitLineBolt ###

The task of splitting lines into individual words after they are read should be the least
performance-critical of the steps in the word counting process. However, it is the kind of task
where we might expect to find many edge cases involving complex string handling. Java is not a
language well suited to string handling, and we can sacrifice some performance here to gain the
string handling niceties of higher level languages without bottlenecking the performance of our
topology. This makes this bolt a perfect opportunity to demonstrate storm's cross-language
capabilities. To add some non java code, we need to create the directory
`src/main/resources/resources` in our project. We then need to place our source code file for the
non java language there. For this bolt, we will write a simple python object that splits the lines
at every space.

```python title="src/main/resources/resources/splitline.py"
--8<-- "lab4/src/splitline.py"
```

TIP: The syntax in the `process` method here is called a "list comprehension". You will often see
comprehensions in python referred to as simple syntactic sugar, but they are much more than that!
They can be a useful optimisation tool, as the syntax limits statefulness and restricts scoping
significantly more than a `for` loop does. This means the interpreter can often optimise
comprehensions to be more efficient than `for` loops.

As previously mentioned: bolts written in languages other than java do need a java wrapper to allow
storm to interface with them. Thankfully, storm makes this process quite straightforward using the
`ShellBolt` class.

```java title="src/main/java/com/csc1104/lab/SplitLineBolt.java"
--8<-- "lab4/src/SplitLineBolt.java"
```

>? TIP: The flags in the python call in our shellbolt here are important for optimising this bolt.
> They take approximately 200ms off of each invocation of the bolt because they:
>
> - `-I`: Enables isolated mode, which skips environment set up. This makes the bolt idempotent and
>     skips a lot of branching code for handling environments.
>
> - `-OO`: Applies aggressive optimisations to the python bytecode.
>
> - `-u`: tells python to use unbuffered standard streams, to ensure data is transferred
>     immediately when processed.

## Creating a Spout 󱡍 ##

Now that we have created our bolts, we need to create a spout that will stream data into our
topology from a data source. For this example, we will create a spout that simply reads a file
line-by-line, and emits each line. This is quite straightforward to do in java, as demonstrated
below.

```java title="src/main/java/com/csc1104/lab/FileSpout.java"
--8<-- "lab4/src/FileSpout.java"
```

>? NOTE: You may notice that most of the code in this spout is actually just for error handling and
> Data acking. Fundamentally, the "happy path" for this code can be boiled down to the lines:
> ```java
> this.reader = new BufferedReader(new FileReader(filePath));
> while (line != null) {
>     String line = reader.readLine();
>     collector.emit(new Values(line));
> }
> this.reader.close()
> ```
> However, it is always important to remember that IO is where most of the errors in any data
> pipeline can occur! So: the better your error handling at your spout, the easier it will be to
> debug your storm topology.

## Building a Topology 󱁉 ##

With all of our building blocks complete, lets combine them into a storm topology for performing
distributed word counts. To do this, we simply need to create a `ConfigurableTopology` class that
creates a graph from our bolts and spout, then submits that topology to the storm cluster.

```java title="src/main/java/com/csc1104/lab/WordCountTopology.java"
--8<-- "lab4/src/WordCountTopology.java"
```

# Building and Running our Topology

With the `WordCountTopology` created, we can now return to the top level of our project (`/lab/`).
Here, we can rely on maven to pull our dependencies, build our classes, and compile the `jar` file
for our storm topology. To do this, we simply need to run:

```sh { .test-block #ghcr.io/amileo/csc1109-lab4:latest }
mvn package
```

>? NOTE: Technically, any directory that contains a pom.xml file is also a valid Maven project. A
> pom.xml file contains everything needed to describe your Java project. Apart from a pom.xml file,
> you also need Java source code for Maven to do its magic, whenever you are calling mvn clean
> install. By convention:
>
> - Java source code is to be meant to live in the "/src/main/java" folder
>
> - Maven will put compiled Java classes into the "target/classes" folder
>
> - Maven will also build a .jar or .war file, depending on your project, that lives in the
> "target" folder.


This will build our `jar` file in the `target` directory. We then need to connect to our client
node, as usual:

```sh
docker compose exec -it client default_shell
```

And once inside the client, we tell the storm cluster to run our topology on the
`data/Word_count.txt` file.

```sh { .test-block #ghcr.io/amileo/csc1109-lab4:latest wrapper='docker compose exec -w /lab/ client {shell} -c "{command}"' }
storm jar target/lab-1.0.0-jar-with-dependencies.jar com.csc1104.lab.WordCountTopology /lab/data/Word_count.txt /lab/out.txt
```

Once the topology has been submitted, you should be able to see it in the active topologies list
for the storm cluster by running:

```sh { .test-block #ghcr.io/amileo/csc1109-lab4:latest wrapper='docker compose exec -w /lab/ client {shell} -c "{command}"' }
storm list
```

You can also see the topology in action by opening your browser and navigating to
[http://127.0.0.1:8000/](http://127.0.0.1:8000/) to open the apache storm monitoring WebUI.

At this point, you should be able to see the current word count for the file you provided by
viewing the file `/lab/out.txt` (by running `cat /lab/out.txt`).

QUESTION: You may notice in your results that this program does not filter out punctuation marks.
As hinted at [previously](#splitlinebolt) this is exactly the kind of string handling operation
that can be cumbersome in Java but easier in Python. Can you improve the word count topology to
have it remove punctuation marks without significantly impacting performance?
