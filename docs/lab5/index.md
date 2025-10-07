---
title: "Lab 5: Spark"
docker_image: ghcr.io/ca4022/csc1109-lab5:latest
volumes:
- host_path: ./docs/lab5/src/
  container_path: /lab/docs_src/
  mode: ro
init_commands:
  - mkdir /lab/src/
  - mkdir /lab/src/main/
  - mkdir /lab/src/main/java/
  - mkdir /lab/src/main/scala/
  - mkdir /lab/src/main/python/
  - cp /lab/docs_src/*.java /lab/src/main/java/
  - cp /lab/docs_src/*.scala /lab/src/main/scala/
  - cp /lab/docs_src/*.py /lab/
  - docker compose up -d --force-recreate
---

{{ "# " ~ page.meta.title ~ " #" }}

This lab will introduce the basics of Apache Spark, deploying a localised spark cluster, running a
spark-shell, and executing spark code written in Java, Scala, and Python.

To download the container for this lab and run it, execute the following commands:

```sh
docker pull {{ page.meta.docker_image }}
docker run --rm --privileged --hostname lab5 -v lab5:/lab/ -v lab_cache:/var/containers/cache/ -p 8000:8080 -p 9870:9870 -it {{ page.meta.docker_image }}
```

If you have already started the lab and wish to resume it after exiting, you can do so by running:

```sh
docker start -ia lab5
```

Once inside the container, you can deploy cluster as a docker stack as normal.

NOTE: Once deployed, the Spark master WebUI will become available at
[http://127.0.0.1:8000/](http://127.0.0.1:8000/) and the Hadoop namenode UI will become available
at [http://127.0.0.1:9870/](http://127.0.0.1:9870/) as in other labs that use Hadoop.

```mermaid
--8<-- "lab5/topology.mmd"
```

## What is Spark? &nbsp; ##

So far, we have explored the evolution of distributed HPC systems and found many powerful
distributed computing **frameworks**. However, between Hadoop, MapReduce, Hive, Pig, Storm, etc; by
the early 2010s programmers found themselves in an extremely fragmented ecosystem. In 2014, Apache
released Spark with the explicit goal of unifying this ecosystem into a single, coherent
**engine**. At the core of this innovation is that keyword: **engine**. By providing a modular
distributed analytics engine with language agnostic APIs, Spark gave rise to a new ecosystem of
open source tools and APIs centred on Spark.

Before Spark a researcher who wanted to use (for example) their existing Storm topology on data in
a Hadoop cluster to preprocess data for ML training via Torch would have to write glue code that
integrates all of these separate services. Nowadays, we can replace the functionalities of all of
these tools with a single engine: Spark. In addition, since Spark is a modular engine that is
programmable via an API, this makes it possible to write a Spark API in any language, not just JVM
based languages. For example, Apache themselves provide Spark APIs for distributed computing in Java,
Scala, Python, SQL, R(1), Go, and Swift. Community supported APIs also exist for Spark in other
languages such as Rust and C#. Because of this, since it's initial release Spark has become the
one of the primary distributed computing tools for computer scientists working on HPC applications,
making it significant driving force behind the current big data and AI/ML revolution.
{ .annotate }

1. Although it is still getting major bugfixes and security patches, the Spark R API is officially
deprecated as of 2025.

## How does Spark work? ##

Rather than providing ways to distribute our analytical code across a cluster, Spark provides a
distributed engine that we can program via APIs in whatever language we choose. This engine is
written in Scala, a language designed specifically for highly concurrent and distributed
systems(1). The Spark engine is built from the ground up  with the goals of reliability,
scalability, and efficiency in mind. And these 2 goals are achieved by 2 primary mechanisms: data
resilience and lazy evaluation. With these mechanisms in place, the final pillar of Spark's
reliability is it's flexibility and the ability to build multiple, transparent layers of optimised
abstractions around these core mechanisms.
{ .annotate }

1. Scala is far from the only language designed for concurrent and distributed systems. Other
languages that excel in this domain include Erlang, Elixir, and Go. However, Scala has the
significant advantage of being based on the JVM, meaning it is able to natively interface with
Hadoop, Yarn, and the majority of the existing tools in the Apache HPC ecosystem. This is a key
reason why Spark was written in Scala.

### Data Resilience ###

The data resilience and fault tolerance the Spark engine is famous for are the result of 2 key
foundational concepts that underpin its data model. These are Resilient Distributed Datasets
(RDDs) and Distributed Acyclic Graphs (DAGs).

#### Resilient Distributed Datasets ####

The RDD is Spark's core abstraction for units of data that are currently being handled. Each RDD is
effectively a partitioned, distributed `List` of immutable, serializable objects. These objects can
be streamed between nodes or even between disk and memory, allowing the engine to exert
fine-grained control over the flow of data. In addition, each RDD is immutable and retains a
"lineage" that can be traced back to (ideally) a fault tolerant immutable source (e.g: Hadoop
inputs or other RDDs). Because all operations on RDDs are required to be deterministic, this
combination of lineage and immutability ensures that RDDs are extremely resilient and can be
readily rebuilt in the event of loss or corruption of data.

```mermaid
--8<-- "lab5/rdd.mmd"
```

#### Distributed Acyclic Graphs ####

We have previously encountered DAGs in our discussion on
[Apache Storm](../lab4/index.md#what-is-a-topology). This model of computation allows us to break
down our work into discrete, repeatable "nodes" of deterministic, repeatable work that can then be
distributed across a cluster. DAGs Make computation more reliable by making operations repeatable
if units of data get lost in flight or corrupted. In the case of Spark, they are especially useful
as when combined with the "lineage" of RDDs they allow us to reconstruct any RDD as long as we
still have access to any ancestor data in the lineage that produced it. The combination of DAGs and
RDDs are a powerful mechanism for resilience that makes the Spark engine one of the most reliable
distributed computing engines available.

### Lazy Evaluation and the Pull-Based Model ###

A core principle of Spark's efficiency is lazy evaluation. This means that Spark doesn't
immediately execute operations, or transformations, when they are declared. Instead, it builds up a
DAG representing the plan of computation. The actual execution is only triggered when an action (an
operation that requests a final result) is called. This "wait-until-asked" approach is implemented
through a pull-based model.

This model stands in sharp contrast to the push-based model used by systems like Apache Storm. In a
push model (e.g., Storm's Spout and Bolt architecture), data is actively pushed through the
processing pipeline as it arrives. Every node in the DAG processes every piece of data, which can
lead to significant wasted computation even if you only need a subset of the final results.

In Spark, when an action is called, the system effectively "pulls" the required data through the
DAG. It requests the final RDD; if that RDD isn't in memory, Spark uses its lineage to request the
necessary data from its parent RDDs. This process continues recursively up the graph. This lazy,
pull-based execution ensures that only data that is **absolutely necessary** for the final result
is computed, naturally minimizing wasted work and enabling highly efficient caching.

### Optimized, Higher-Level Abstractions ###

Around these core mechanisms, Spark's architecture makes it possible to build flexible, highly
optimised abstractions that allow users to quickly reach for simple prebuilt toolboxes for common
data processing tasks (similar to the benefits we discussed in our lab about
[Pig](../lab3/index.md#what-is-pig)). However, by making these abstractions transparent Spark
allows the user to work at a lower level where required allowing for a progressive disclosure of
complexity(1) to the user. The key classes that Spark makes available for this (from lower level of
abstraction to higher level) are the `Dataset` object and the `DataFrame`. These more abstract
classes provide a convenient way to interact with the lower level RDDs, while providing a sizeable
toolkit of robust, well optimized methods for handling them.
{ .annotate }

1. In modern library design, progressive disclosure of complexity is an important design philosophy.
This term describes systems where complex, lower level systems have transparent, higher levels of
abstraction that users can interact with. This allows the user to use high level abstractions if
they choose, while inviting them to use lower level abstractions where appropriate. In addition, a
well designed progressive disclosure model for a library or API allows users to passively learn how
more experienced users utilise lower level abstractions in the process of using the higher level
abstractions. Spark is often cited as a perfect example of a library that does this well.

NOTE: When using  the `Spark.SQL` API (which provides the `Dataset` and `DataFrame` classes), all
API calls are optimised using an optimization engine called `Catalyst`. The `Catalyst` optimizer is
a hybrid rules-based and cost-based optimizer, not dissimilar to the optimizer in a traditional
relational database. However, instead of optimizing a query into an execution plan it optimizes
them into a **DAG**.

#### DataFrames ####

A `DataFrame` is Spark's primary abstraction for working with structured tabular data. It's an
immutable, distributed collection of data organized into named columns, conceptually similar to a
table in a relational database or a `DataFrame` in Python's pandas library. Under the hood, a
`DataFrame` is essentially an RDD of generic Row objects with an attached schema that describes
the data types of each column.

This schema is the key to a `DataFrame`'s power. It allows Spark's **Catalyst optimizer** to
understand the data's structure and the user's intent, enabling it to generate highly optimized
physical execution plans. This can lead to massive performance gains over raw RDDs through
techniques like predicate pushdown and column pruning, where filtering and data selection happen at
the data source, minimizing data transfer. They also offer a rich, high-level API with familiar
operations like `select()`, `filter()`, `groupBy()`, and `agg()`, making complex data manipulations
more concise and readable. Furthermore, any DataFrame can be queried using standard SQL, making
Spark accessible to data analysts and scientists, not just engineers.

#### Datasets ####

The `Dataset` API began as an extension of the DataFrame API that provides strong compile-time type
safety. As the `Dataset` abstraction has evolved and become more optimised though, it has subsumed
much of what Spark originally handled with `DataFrame`s. You can think of a `Dataset` as a typed
`DataFrame`. In fact, in Scala and Java, a `DataFrame` is simply an alias for `Dataset[Row]`. A
`Dataset[T]` is a distributed collection of objects of a specific JVM type `T`.

This powerful abstraction combines the benefits of RDDs (strong typing, the ability to use powerful
lambda functions) with the performance optimizations of DataFrames (the Catalyst optimizer). By
working with typed objects, you can catch errors at compile time rather than runtime, making your
code significantly more robust and maintainable. Additionally, `Datasets` use specialised encoders
to efficiently serialize objects into Tungsten's binary format. This is often much faster than
standard Java serialization used by RDDs, leading to improved performance for many operations. It's
important to note that the `Dataset` API is primarily available in JVM languages like Scala and
Java. In dynamically typed languages like Python, the `DataFrame` remains the primary high-level
structured API.

<figure markdown="span">
    <img class="center", src="../assets/img/fireworks-spark.webp", alt="Apache Spark Fireworks"/>
    <figcaption>Congratulations! You are now all caught up on the underlying systems of modern
    distributed computing! Give yourself a clap on the back and lets start practically applying
    that newly developed expertise!</figcaption>
</figure>

INFO: Spark has greatly influenced many later tools that use a similar execution model in modern
big data handling. Most notably, much of the data science community has recently been gradually
adopting distributed engines that are somewhat easier to program for such as
"Dask". Dask works similarly to Spark but is designed from the ground-up with python programming
in mind. Despite this, Spark remains the primary pillar of the ecosystem, and offers a level of
reliability, resilience and production readiness that younger, user friendly tools like Dask can't yet match.

## A Programming Polyglot Tour of Spark Examples ##

In this section, we will walk you through running our familiar distributed word count on the Spark
engine in several languages. To start, we will show you an example in Java, a language you should
already be familiar with. Then, we will give some examples showcasing Spark's various levels of
abstraction in Scala, the native language of the Spark engine. Finally, we will show a more high
level example written in the favoured language of data scientists: Python. This should help
familiarise you with programming Spark in various languages, the general patterns of Spark
programming, and showcase its usefulness as a unified analytics engine.

### Java ###

As a familiar starting point, lets write a simple program that uses Spark RDDs to perform a
distributed word count on a file. If you look at our `pom.xml` you will see that it has already
been configured to compile a multilanguage project into several separate and one combined jar file.
To begin writing Spark code, lets create the directory `src/main/java` and write the following
source file to it:

```java title="src/main/java/WordCountJava.java"
--8<-- "lab5/src/WordCountJava.java"
```

Once this source file has been created, we can compile it by running maven, as usual.

```sh { .test-block #ghcr.io/ca4022/csc1109-lab5:latest }
mvn package
```

The package can then be submitted to the Spark cluster to run using the following command.

```sh { .test-block #ghcr.io/ca4022/csc1109-lab5:latest wrapper='docker compose exec -w /lab/ client {shell} -c "{command}"' }
spark-submit --class WordCountJava --master spark://spark-master:7077 target/lab-1.0.0.jar hdfs://namenode/data/Word_count.txt hdfs://namonode/output/java/
```

WARNING: Remember to connect to the client node in the cluster before running this command! If you
don't connect to a gateway node you won't be able to find "spark-master" on your local network.

INFO: Remember to move your files to the hadoop cluster before running this on the spark cluster!
If you need a refresher on how to do this, refer back to
[Lab1](../lab1/index.md#adding-a-file-to-the-hdfs-cluster).

NOTE: You can also run this locally by running without the `--master` flag. If you do this, you
will only be using the local node to compute. This is useful for debugging because you can run the
program locally without the need for a spark cluster or a centralised hadoop cluster

You should now see `WordCountJava` running in the Spark master WebUI, and when it is finished
running you should see the result outputs in the `output/java` directory. You can check the
contents of these results by running `cat output/java/*`.

### Scala ###

As the native language of Apache Spark, Scala is often the most capable and straightforward
language to use when interacting with the Spark engine. For example, Spark developers using
Scala can use a REPL for quick analyses or to help them develop components. This REPL is simply
a normal Scala shell preloaded with the Spark dependencies and some convenience functions that
facilitate Spark development. When working in Scala, we also have access to all the various layers
of abstraction that Spark offers. Here, we will begin with a brief walkthrough of how we can
perform a word count via the Scala REPL. Then, we will show 2 simple examples of word count
programs written in Scala, one directly using RDDs, the other using `DataSet`s. We will not be
demonstrating `DataFrame`s here, as they are intended for tabular data and so are not the right
abstraction for this task, however you can find some examples of Spark code using the `DataFrame`
API [below](#further-reading-examples).

Note: The suggested version of Scala is 2.13.X, but there should be very little compatibility issues
with Scala 3. The recommended version for Apache Hadoop 3 and later is Spark 4.0.0 (last release)
pre-built. In this lab, the lab environment container is using Spark 4.0.0, Scala 2.13.12, and
Hadoop 3.4.1.

#### Using the REPL ####

To begin our REPL introduction, let's try and run the toy example from spark RDD slides.

  - Run Spark shell in local mode by running `spark-shell`
  - Use the Scala code from slides:

```scala
scala> val pets = sc.parallelize(List(("cat", 1), ("dog", 1), ("cat", 2)))
scala> val pets2 = pets.reduceByKey((x, y) => x + y)
scala> val pets3 = pets2.sortByKey()
scala> pets3.saveAsTextFile("pet-output/")
```

  - Verify the output by running `cat pet-output/part-0000`

TIP: At any time, you can visualise the content of an RDD using `RDDname.take(n).foreach(println)`
(better for big RDDs, prints only the first `n` elements) or `RDDname.collect().foreach(println)`.

To run Wordcount on a file in local Standalone mode from Spark Shell we can run the following.

```scala
scala> var lines = sc.textFile("data/Word_count.txt")
scala> var lower = lines.map(_.toLowerCase)
scala> var words = lower.flatMap(_.split("[^a-zA-Z']+"))
scala> var nonEmptyWords = words.filter(_.nonEmpty)
scala> var ones = nonEmptyWords.map((_, 1))
scala> var counts = ones.reduceByKey(_ + _)
scala> counts.saveAsTextFile("output/scala-repl")
```

NOTE: Notice how we have followed a similar structure here to our Java program. The previous
Java code had be written in a more functional style to conform to what Spark expects, but this
effectively identical code is much clearer and cleaner in Scala.

To instead run a REPL on the distributed Spark cluster, we simply need to add the `--master` flag
to tell Spark which master node to connect to.

WARNING: Remember to connect to the client node before doing this! Otherwise your host will not be able
to find the master node as it is not in the same network.

```sh
spark-shell --master spark://spark-master:7077
```

Once you have opened a distributed REPL, you should see the Spark shell process appear in the
"Running Applications" section of your Spark master WebUI. Once you have a distributed shell,
you should be able to simply run the same commands to get the same result, but this time
computation will be distributed across the entire cluster.

QUESTION: When running Spark on a distributed cluster, you can use local files as we did before.
However, this means that all file reads must be done by the master node creating an IO bottleneck.
Recalling [Lab 1](../lab1/index.md), can you figure out how to do this distributed computation
using HDFS for distributed and more resilient IO?

#### Using RDDs ####

In the REPL, we already demonstrated the direct use of RDDs to perform a word count, and writing
a program to do this follows much the same pattern. Doing this programmatically does provide us
with some opportunities to further optimise the code, in addition to adding some better error
handling. Since maven is already configured to build our Scala files too, lets create the directory
`src/main/scala` and place the following source code inside that directory.

```scala title="src/main/java/WordCountRDD.scala"
--8<-- "lab5/src/WordCountRDD.scala"
```

Then, we simply rebuild the package using maven.

```sh { .test-block #ghcr.io/ca4022/csc1109-lab5:latest }
mvn package
```

Our jar file has now been recompiled to include our new Scala `WordCountRDD` class. We then submit
this class as before.

```sh { .test-block #ghcr.io/ca4022/csc1109-lab5:latest wrapper='docker compose exec -w /lab/ client {shell} -c "{command}"' }
spark-submit --class WordCountRDD --master spark://spark-master:7077 target/lab-1.0.0.jar hdfs://namenode/data/Word_count.txt hdfs://namonode/output/scala-rdd/
```

#### Using Datasets ####

This approach using RDDs is very effective, and demonstrates how to write code that directly
interacts with the fundamental data structures underpinning Spark, but modern spark also has more
abstracted structures that allow us to do higher level operations to achieve our goal using highly
robust and optimised code from the Spark library. For example, we can perform a much more optimised
and reliable word count than that in the previous section by using `Dataset`s as follows.

```scala title="src/main/java/WordCountDS.scala"
--8<-- "lab5/src/WordCountDS.scala"
```

Then, as before, we simply rebuild the package using maven.

```sh { .test-block #ghcr.io/ca4022/csc1109-lab5:latest }
mvn package
```

And we can resubmit the same job using this `WordCountDS` class.

```sh { .test-block #ghcr.io/ca4022/csc1109-lab5:latest wrapper='docker compose exec -w /lab/ client {shell} -c "{command}"' }
spark-submit --class WordCountDS --master spark://spark-master:7077 target/lab-1.0.0.jar hdfs://namenode/data/Word_count.txt hdfs://namonode/output/scala-ds/
```

This approach is considered best practice where possible in modern Spark programming, as it allows
us to write highly optimised and robust code. When writing your own Spark code take care and
remember to use the `Dataset` (and associated `DataFrame`) abstractions where appropriate without
forgetting that you can directly manipulate the RDDs where necessary. Approaching your Spark
programs with a proper understanding of these various levels of abstraction will already place you
ahead of most other programmers in HPC programming capabilities.

### Python ###

Lastly, we will showcase what is perhaps Spark's best known and most used API: `pyspark`. This
library provides a high level API for interacting with the Spark engine from python code. Using
this API, Spark is been integrated into many of the most prominent tools for data science in the
python ecosystem, including but not limited to `numpy`, `pandas`, `sklearn`, `tensorflow` and
`pytorch`(1). Spark's ability to provide a single engine that can be interacted with via languages
such as python is a key factor in why it has risen to prominence over the many other distributed
computing tools we have encountered so far(2).
{ .annotate }

1. Many of these tools are also APIs for highly optimised code in other languages. For example,
`numpy` is largely based on Fortran code, and `torch` is written in C++. Python's powerful FFIs
and flexibility of abstraction make it perfect for writing inter-language glue code, which is why
it is so favoured by data scientists despite its relatively low performance.
2. Several other tools we won't be covering here such as Apache Flink and Google's FlumeJava also
use this distributed engine approach to data parallelism. All were first released around the same
time with very different implementations. These various engines were inspired by Microsoft's
"Dryad" research project several years earlier which first demonstrated the application of a
general purpose distributed execution engine for DAGs at large scale.

#### Using the REPL ####

Similar to the Spark scala REPL, we can easily open a python REPL by running `pyspark`. Once inside
this REPL, we can begin testing out some functions to design a simple python script that will do
our distributed word count task. The following lines will perform a word count via the Spark engine
in python.

```python
 >>> lines = sc.textFile("hdfs://namenode/data/Word_count.txt")
 >>> lower = lines.map(lambda line: line.lower())
 >>> words = lower.flatMap(lambda line: re.split(r"[^a-zA-Z']+", line))
 >>> non_empty = words.filter(bool)
 >>> ones = non_empty.map(lambda word: (word, 1))
 >>> counts = ones.reduceByKey(int.__add__)
 >>> counts.saveAsTextFile("hdfs://namenode/output/python-repl")
```

NOTE: You may notice if you try to examine one of your variables here that they do not appear to
contain any actual results. Remember: this is because Spark executes **lazily**. Instead of
thinking of these variables as pointing to data, you can think of them as pointing to nodes in the
DAG. As we run these lines of code, we build a DAG representing a data processing pipeline. If we
want to examine the state of the RDD at one of these nodes we need to call the `collect` method to
trigger execution of the DAG and the generation of lineages and RDDs up until that node.

TIP: Although we have provided these lines to test in the REPL, we encourage you to experiment and
explore in this `pyspark` shell. The `pyspark` API gives powerful control over the Spark engine
from the comfort of an extremely flexible high level language. It is the perfect environment for
quick experimentation and learning about how to effectively program Spark.

#### Using RDDs ####

The lines of code that worked in the pyspark REPL could be directly placed in a python file and run
as-is to achieve the same result(1). However, in the process of creating a script we probably want
to organise our code into functions, optimise some operations, and improve our error handling and
resource management. If we do this, we end up with code that should resemble the following.
{ .annotate}

1. As long as we remember to initialise a `SparkContext`

```python title="WordCountRDDPython.py"
--8<-- "lab5/src/WordCountRDDPython.py"
```

NOTE: the examples are using SparkSession instead of SparkContext. SparkSession (also available
from the spark shell) unifies all Spark functionalities (SparkSQL, SparkStreaming, ...) including
those available in SparkContext (SparkCore). It prevents you from having to create different
SparkContext for different groups of functionalities.

We can use `spark-submit` to submit this `pyspark` script similarly to how we used it for direct,
JVM objects interacting with Spark.

```sh { .test-block #ghcr.io/ca4022/csc1109-lab5:latest wrapper='docker compose exec -w /lab/ client {shell} -c "{command}"' }
uv run spark-submit --master spark://spark-master:7077 WordCountPythonRDD.py hdfs://namenode/data/Word_count.txt hdfs://namonode/output/python-rdd/
```

WARNING: Here, we **need** to use `uv` to run the command, as this runs `spark-submit` in an
environment that is pinned to `python3.10`. Running without `uv run` will cause `spark-submit` to
run using the container's system python interpreter, which is `python3.6`, raising a
`ModuleNotFound` error as `python3.6` lacks the `importlib.resources` package which `pyspark`
needs.

#### Using DataFrames ####

Although the RDD approach in the previous section is straightforward and works well, it would not
be considered ideal for "modern" `pyspark` code. In modern Spark, we tend to use the higher
`DataFrame` API where possible, and leave the `Catalyst` optimizer to create an optimized DAG
instead of directly writing a DAG like we did in the RDD approach. Do to this, we must replace our
functional operations in the `word_count` function with declarative calls to the `pyspark.sql` API.
This approach is less flexible than directly writing a DAG ourselves, but generally results in a
more optimized execution DAG for common operations.

```python title="WordCountDFPython.py"
--8<-- "lab5/src/WordCountDFPython.py"
```

Similar to in our previous example, we can simply submit this via the `spark-submit` program.

```sh { .test-block #ghcr.io/ca4022/csc1109-lab5:latest wrapper='docker compose exec -w /lab/ client {shell} -c "{command}"' }
uv run spark-submit --master spark://spark-master:7077 WordCountPythonRDD.py hdfs://namenode/data/Word_count.txt hdfs://namonode/output/python-df/
```

QUESTION: So far, when running distributed code we have been accessing files on our Hadoop cluster.
However, often, we want the cluster to run computations on files that are on the client's local
drive without needing to deploy a whole hadoop cluster. Can you figure out how to do this by
modifying the code provided? (HINT: you can easily broadcast data across a Spark cluster in python
using the `sc.broadcast` method)

## Further Reading & Examples &nbsp; ##

- [Running built-in Spark examples](http://spark.apache.org/docs/latest/)
- [Spark quickstart page](https://spark.apache.org/docs/latest/quick-start.html#basics)
- [Scala Spark shell example](https://www.tutorialkart.com/apache-spark/scala-spark-shell-example/)
- [Hadoop and Spark common errors, April 2020](https://medium.com/analytics-vidhya/9-issues-ive-encountered-when-setting-up-a-hadoop-spark-cluster-for-the-first-time-87b023624a43)
- [Spark Examples](https://spark.apache.org/examples.html)
