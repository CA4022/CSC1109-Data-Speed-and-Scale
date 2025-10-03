---
title: "Bonus Lab 3: To BEAM, or not to BEAM 󰓉&nbsp;&nbsp;"
docker_image: ghcr.io/ca4022/csc1109-bonus3:latest
volumes:
- host_path: ./docs/bonus3/src/
  container_path: /lab/src/
  mode: ro
init_commands:
  - cp -r /lab/src/* /lab/
  - elixirc *.ex
---

{{ "# " ~ page.meta.title ~ " #" }}

Throughout this course, we have extensively covered an approach to distributed computing that we
could classify as **"Data Parallelism"**. Data parallelism is the model of distributed computing where
we design a mechanism for distributing data and then write programs around that which perform
computations on those distributed data pieces. This approach is best exemplified in the concept of
the RDD, as discussed in [Lab 5](../lab5/index.md#resilient-distributed-datasets). However, despite
its prominence in HPC, this is not the only approach that exists to distributed computing. In this
bonus lab, we invite you to take a brief foray into the other main branch of distributed computing:
**"Process Parallelism"**.

To download the container for this lab and run it, execute the following commands:

```sh
docker pull {{ page.meta.docker_image }}
docker run --rm --privileged  --systemd=true --hostname bonus3 --network host -v bonus3:/lab/ -it {{ page.meta.docker_image }}
```

## Process Parallelism ##

Process parallelism much more closely resembles the kind of parallelism you have likely already
encountered when programming in a purely local context (e.g: using threads or multiprocessing). In
fact, it is the exact same paradigm of parallel computing we usually use in this context! However,
stretching this familiar model that works locally across a network takes the familiar issues with
this paradigm locally and cranks them up to 11. The familiar cracks like race conditions that exist
in this model on a local scale become gaping chasms that are extraordinarily difficult to navigate.

<div class="annotate" markdown>
- Communication (1)
- State and Synchronization (2)
- Failure and Fault Tolerance (3)
- Location Transparency (4)
</div>

1. Processes on a single machine can communicate very efficiently and reliably through shared
    memory or operating system primitives. In a distributed system, processes must communicate over
    an unreliable network. This introduces significant latency, requires data to be serialized and
    deserialized, and forces us to handle message loss or network partitions.
2. When processes on different machines need to coordinate or share state, we can no longer rely on
    simple, fast, in-memory locks or mutexes. Implementing distributed synchronization primitives
    (like a distributed lock) is extremely complex and can become a major performance bottleneck,
    creating a challenge for maintaining data consistency across the system. In local parallel
    processes, we have ~100ns latency that can cause issues such as race conditions unless we use a
    blocking mutex. In a distributed system on a good, consumer grade LAN system this latency
    increases to an absolutely glacial level of up to 5ms (5,000,000ns). This represents a 50,000×
    slowdown for any process involving a mutex in a distributed setting! For perspective: if it
    took you 1 minute to read this annotation, then a 50,000× slowdown to your reading speed would
    make it take **35 days to read this annotation!!!** Clearly, the solutions we use for this
    problem locally won't work here.
3. In a local context, if the program or machine crashes, everything stops. In a distributed
    system, one node can fail while the others continue running. This concept of partial failure is
    a fundamental challenge. The system must be able to detect when a remote process or node has
    failed and have a strategy to recover from that failure gracefully, a problem that is far more
    complex than in a single-machine environment.
4. On a single computer, the operating system gives us a straightforward way to identify and
    communicate with any process (e.g., via a process ID). In a distributed system, how does a
    process on node A find and talk to a process on node B (or node C, or node D...)? We need a
    system for addressing and locating processes that is independent of the physical machine they
    are currently running on.

<div class="annotate" markdown>
Many different models for distributed process parallelism have been developed over the years
attempting to scale familiar, local process concurrency patterns(1), each finding varying degrees of
success. However, similar to how the distributed DAG model emerged as the most reliable and
successful model on the data parallelism side of the distributed HPC family tree: the "actor model"
is often considered the most reliable and robust model for distributed process parallelism. The
actor model of process parallelism provides compelling solutions to the challenges highlighted
above:

1. Communication: Actors communicate only via asynchronous messages, abstracting away the network.
2. State: Each actor has its own private state, eliminating the need for distributed locks. Each
    piece of data inherently belongs to a single thread.
3. Failure: Actors are isolated. If one fails, it doesn't bring down others. Supervisors can then
    implement recovery strategies. This allows us to take a "let it fail" approach, simply
    restarting a process if it fails.
4. Location Transparency: Actors are addressed by a name/PID, not an IP address. The runtime
    handles routing the message to the right machine.

The most prominent example of a system used for distributed, actor based process parallelism is the
Erlang BEAM, which underpins many of the highest volume distributed systems you probably interact
with regularly such as telecoms switching systems (including much of the world's mobile and fixed
telephony infrastructure), online gaming platforms, livestreaming platforms (e.g: Twitch), and
messaging services like WhatsApp and Discord.
</div>

1. For example: the "fork-join" model, "producer-consumer" model, or the "scheduler-executor"
    model.

??? QUESTION

    Did you know that it is debated to this day whether "object oriented programming" as we
    use the term today is **actually** what that term was originally supposed to mean? The reason
    for this debate is actually the same reason you might be questioning whether this "actor model"
    is just an extreme version of OOP. "Smalltalk", often considered the first(1) and definitely the
    most influential OOP language actually works in a way that more closely resembles this "agent
    model" than modern OOP! When asked about modern OOP the creator of Smalltalk, Alan Kay, has
    said he wouldn't consider it to be in line with what was originally intended in his language,
    saying that
    { .annotate }

    1. Despite the consistent claim of Smalltalk as the "first" OOP language, I would argue that
        "Simula" (which predates it by over a decade) has all the features of OOP and simply lacks
        the terminology invented by Smalltalk.

    !!! QUOTE "Alan Kay - 2003"
        OOP to me means only messaging, local retention and protection and hiding of state-process,
        and extreme late-binding of all things.

    In this framing of OOP, Erlang could be considered **far** more OOP than Java!

## The BEAM ##

The Erlang BEAM is a VM similar to the JVM, but is designed from the ground up to run in a
distributed fashion across multiple nodes. This architecture is similar to
[Apache Storm](../lab4/index.md) (1), but in the BEAM we are programming for a single, distributed
system comprised of several VMs, whereas in Storm we were programming for an abstraction on top of
multiple, local, general purpose VMs linked together. This inherently distributed system allows the
BEAM VM to perform many, cluster aware operations that simply aren't practically possible in a
system like Storm, such as direct process-to-process communication, live distributed introspection,
and hot code swapping. Utilising this unique process-to-process capability, programs that run on
the BEAM generally make use of many **actors**(2) that communicate among themselves. The BEAM then
maintains a set of **supervisors** that monitor these processes, and restart any that fail. The
BEAM also maintains multiple **schedulers**, usually one per core on each node in the cluster.
These schedulers are responsible for managing hundreds (or even thousands) of asynchronous
processes, incorporating features such as process migration logic which reassign processes within a
node on-the-fly depending on resource availability (a process called "work stealing") (3). Using
third party modules such as `Horde`, it is even possible to extend the BEAM by adding
"super-schedulers", that provide inter-node process management and migration based on cluster-wide
resource availability and data locality(4).
{ .annotate }

1. In fact, it could be argued that Storm was an attempt to "bolt on" a BEAM-like system to the JVM
2. Actors are, effectively, asynchronous, object-like processes or "services" with isolated memory
    (all their "attributes" are inherently private). This "actor" model allows for robust
    statefulness, allowing the BEAM to be used for **general purpose** programming of distributed
    systems, unlike the stream-processing limitations inherent to Storm's stateless model.
3. This behaviour is distinct from systems like Storm, as it requires a level of cluster
    introspection they simply can't reliably achieve
4. This behaviour would be unimaginable difficult to implement in Storm, as it requires a kind of
    distributed, cluster-wide introspection that Storm simply doesn't provide

Originally developed by Ericsson to be the backbone of their massive, distributed, transcontinental
telecoms network; the BEAM VM was open sourced in 1998 along with the "Erlang" language for
programming it as part of the "Open Telecoms Platform". This has led to the emergence of an entire
ecosystem of languages that run on the BEAM VM, such as elixir, clojerl, and gleam. Of these,
elixir is the most popular (eclipsing erlang itself). Here, we will demonstrate some distributed,
process parallelised computations on the BEAM using elixir.

While the BEAM's roots are in telecommunications, its principles of fault tolerance and massive
concurrency are finding new life in the world of AI and data engineering. The Elixir ecosystem has
recently seen the development of powerful tools like:

- Nx (Numerical Elixir): A library that brings TensorFlow/PyTorch-style tensor computations to the
    BEAM, complete with pluggable backends for compiling to CPUs and GPUs.
- Axon: A deep learning library built on Nx for creating neural networks.
- Livebook: An interactive and collaborative code notebook environment (akin to Jupyter) built in
    Elixir.

This combination allows developers to build robust, distributed data ingestion pipelines, serve
machine learning models at massive scale, and perform interactive data analysis, all within the
same fault-tolerant runtime. The BEAM's lightweight processes are perfectly suited for building
data pipelines that can handle millions of concurrent events or for serving thousands of individual
ML model instances simultaneously(1).
{ .annotate }

1. Imagine a service like ChatGPT where each user could have their own dedicated, lightweight BEAM
    process running a model instance. This process holds the user's specific context (e.g., their
    recent code, their conversation history). Thanks to the BEAM's "let it fail" philosophy, if
    one user's model process crashes, it is instantly restarted by its supervisor without
    affecting any other user. This provides massive scalability and resilience that is very
    difficult to achieve with traditional monolithic server architectures.

??? INFORMATION

    A primary reason that elixir has become the favoured BEAM programming language is
    because of its clever use of syntactic semantics and other abstractions for actor isolation.
    Translated into plain English: the elixir language's syntax is carefully designed so that it
    makes it easy to get the most out of the BEAM VM. The elixir compiler is very good at guiding
    the programmer to patterns that produce better BEAM bytecode. It encourages better process
    isolation, discourages side-effects between processes, and provides a standard library that
    localises unreliable code (such as IO code) into as few minimal processes as possible. It also
    has a very active and enthusiastic community that maintain a vibrant collaborative ecosystem.
    All of this allows us to use elixir to efficiently leverage the BEAM VM without many of the
    headaches of doing it manually in Erlang!

    ??? FAILURE
        To keep with our tradition of naming bonus labs with bad puns that are relevant to that lab:
        I considered going with "Double, bubble, toil, and trouble" for this one as a nod to elixir
        and how it can effortlessly double-up on (i.e: parallelise), create isolated process
        "bubbles", and share work (aka: "toil"). As punny as that would have been, I decided
        against it because for this kind of work elixir actually takes most of the "toil and
        trouble" out of process parallelism!!!

## Elixir Code: Programming on the BEAM ##

Elixir is extremely flexible in how you use it to execute programs. You can compile an elixir
program using `elixirc`, you can run it using the `elixir` runtime, you can run it interpreted or
interactively using `iex`, and it even includes its own package manager (similar to `uv` or `maven`)
called `mix`. Using these tools, we have provided below a collection of elixir code examples that
demonstrate the basic features of the language with regards to local and distributed computing,
culminating in our classic word count example, similar to those we used to demonstrate the other
tools you've used in this lab.

TIP: Elixir is a general purpose, functional programming language so try to think in the FP
paradigm when using it. If you are familiar with Scala, Scheme, Clojure, or Haskell then you should
feel right at home using this language.

NOTE: Since the BEAM distributes work in the same way whether it is running locally or on a
distributed system, we will be running it locally here for the sake of convenience. If you wish
to explore further and run your BEAM on a cluster, including the use of a distributed scheduler
you can check out `Horde`'s documentation [here](https://hexdocs.pm/horde/getting_started.html).

![Elixir Scaling Ghidorah Meme](../assets/img/elixir-scaling.webp#center)

### Hello World ###

```elixir title="hello.ex"
--8<-- "bonus3/src/hello.ex"
```

You can run this in any of the following ways:

- Interactive: `iex hello.ex` then run `Lab.Hello.run` inside the REPL
- Interpreted: `elixir -r hello.ex -e Lab.Hello.run`
- Compiled: Run `elixirc hello.ex` and this will produce an `Elixir.Lab.Hello.beam` BEAM bytecode
    file, then you can easily use this bytecode in any environment that interacts with the BEAM.
    For example:
    - `elixir`: we can directly run our function via the elixir runtime, by running
        `elixir -e Lab.Hello.run`
    - `iex`: it will automatically be loaded without the need to include the file. Simply run
        `Lab.Hello.run` and it will execute.
    - `erl`: It will also be automatically present in the Erlang shell, `erl`. The only caveat is
        that you must manually load the elixir standard library in `erl` before running any BEAM
        bytecode that uses it. For example, as shown below:
        ```erlang
        code:add_path("/usr/local/lib/elixir/lib/elixir/ebin").
        'Elixir.Lab.Hello':run().
        ```

TIP: If you have a directory full of `.ex` files and you want to be able to quickly and easily
compile them all to use interactively in `iex`, you simply need to run `elixirc *.ex`. Just
remember to make sure you won't create any namespace conflicts if you do this!

### nth Fibonacci Number ###

```elixir title="fibonacci.ex"
--8<-- "bonus3/src/fibonacci.ex"
```

### Slow, Concurrent Tasks ###

```elixir title="slow.ex"
--8<-- "bonus3/src/slow.ex"
```

This function creates a process that just sleeps for one second and writes that it is finished
processing the input to stdio. We can use this to demonstrate simple concurrency in elixir. In your
`iex` shell you can time any function using the `:timer.tc` function. You can then run the
following to see concurrency in action:

```elixir { .test-block #ghcr.io/ca4022/csc1109-bonus3:latest }
# The following line maps our `run` function onto the numbers 1 to 5 synchronously
:timer.tc(fn -> Enum.map(1..5, &Lab.Slow.run/1) end) # this should take >5s
# Instead, this line runs maps `run` in concurrent processes, taking <5s
:timer.tc(fn -> Task.async_stream(1..5, &Lab.Slow.run/1) |> Enum.to_list() end)
```

The only difference between the two is that one uses `Enum.map` to run the function calls
sequentially in the current process, whereas the other uses `Task.async_stream` to lazily queue
one distinct process for each element, then pipes those processes to `Enum.to_list` which requests
and collects them. This perfectly demonstrates the power of the actor model and BEAM: there is no
"function colouring" between sync and async, parsing off an asynchronous process is as simple as
telling the BEAM to run your code in its own process instead of the current one.

### Counter Using Messages ###

```elixir title="counter.ex"
--8<-- "bonus3/src/counter.ex"
```

Now, we can start our counter and interact with it to see it work.

<!-- NOTE: We can't test this block because it DELIBERATELY causes a crash! -->
```elixir
Lab.Counter.start_link # You could also start it with an initial value, e.g: `start_link(2)`
Lab.Counter.read # Should start at 0
Lab.Counter.increment
Lab.Counter.read # Should be 1 now
Lab.Counter.increment
Lab.Counter.read # Should be 2 now
Enum.each(1..5, fn _ -> Lab.Counter.increment end) # We can call multiple times at once
Lab.Counter.read # Should be 7 now
Lab.Counter.crash # Lets trigger a crash on purpose!
Lab.Counter.read # Oh, it didn't recover automatically...
Lab.Counter.start_link
Lab.Counter.read # At least we can restart it without crashing the VM
```

As you probably noticed while running this sequence of commands: if the `Lab.Counter` process
crashes, we need to restart before we can continue to use it. It's nice that the VM didn't crash
too, and at least we can restart it, but where's that famous BEAM fault tolerance? Well, if we want
it to restart itself, all we have to do is create a custom supervisor that knows this is how we
want it to handle crashes.

#### Supervising the Counter (The BEAM and Errors) ####

So far we have been using the BEAM's default supervisors that are automatically assigned to spawned
processes. However, if we want som more custom functionality, we can always create a custom
supervisor for processes we want finer control over. For example, we can easily create a supervisor
for our `Lab.Counter` process as shown below:

```elixir title="supervisor.ex"
--8<-- "bonus3/src/supervisor.ex"
```

Now, we can run the counter in a supervised way by running `Lab.Counter.Supervisor.start_link`
instead of running `start_link` directly on the counter. This starts the counter in a fault
tolerant, supervised way that will restart automatically if it crashes. You can test this as
before, and note the new behaviour after you call `crash`.

### Word Count ###

Below is an elixir implementation of the same distributed wordcount algorithm we have been using
to demonstrate the other distributed computing systems covered in this course. Unlike our Spark
implementation where data flows through a static DAG, our Elixir version will use a dynamic pool of
worker processes managed by a supervisor. The main process will stream lines from the file, sending
each line as a message to an available worker. Each worker will count the words in its chunk and
send its result back to the calling node, which reduces and aggregates the final totals. This
showcases a "Coordinating Process" pattern common in stateful, highly concurrent systems. Compared
to the other implementations, this one has a few other key flavour differences that might jump out
at you immediately.

1. It handles input and outputs as messages, using the "input normalisation pattern" and
    "strategy pattern" that you will find are very common in this kind of actor based programming.
    This allows us to change the inputs and outputs of the distributed wordcount using pattern
    matching.
2. Related to point 1: you may notice that these inputs and outputs are able to be "anchored" to
    the node from which the call was made. Even when running a distributed computation, we have no
    need for a hadoop cluster, we can just distribute the data to the workers via the BEAM, and
    collect it once processing is complete.
3. This process is supervised by a dynamic, resource aware supervisor that we can reference from
    within our code. This gives us a lot of flexibility, including the ability to interact with the
    supervisor on-the-fly to optimise computational operations.

```elixir title="wordcount.ex"
--8<-- "bonus3/src/wordcount.ex"
```

To perform our usual test word count, we can simply run:

```elixir { .test-block #ghcr.io/ca4022/csc1109-bonus3:latest }
Lab.WordCount.count_words({:file, "data/Word_count.txt", "out.txt"})
```

QUESTION: As a final challenge: can you get this running on a true, distributed cluster? Even by
simply connecting 2 laptops or making a BEAM cluster with your friend next to you? It is
surprisingly easy to do using `iex`'s `--sname` flag. You may need to run the container with the
network in `host` mode though to bypass docker's builtin network isolation!

## Further Reading & Examples &nbsp; ##

- [The BEAM Book](https://blog.stenmans.org/theBeamBook/)
- [BEAM By Example](https://gomoripeti.github.io/beam_by_example/)
- [Steps from Elixir source code to BEAM bytecode](https://elixirforum.com/t/getting-each-stage-of-elixirs-compilation-all-the-way-to-the-beam-bytecode/1873)
- [Elixir Learning Resources](https://elixir-lang.org/learning.html)
