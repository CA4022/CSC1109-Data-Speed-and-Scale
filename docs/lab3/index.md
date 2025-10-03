---
title: "Lab 3: Pig"
docker_image: ghcr.io/ca4022/csc1109-lab3:latest
---

{{ "# " ~ page.meta.title ~ " #" }}

This lab covers the basics of Apache Pig with examples.

To download the container for this lab and run it, execute the following commands:

```sh
docker pull {{ page.meta.docker_image }}
docker run --rm --privileged --systemd=true --hostname lab3 -v lab3:/lab/ -v lab_cache:/var/containers/cache/ -p 9870:9870 -p 19888:19888 -it {{ page.meta.docker_image }}
```

## What is Pig? 󱀆&nbsp; ##

In our previous lab we discovered Apache Hive, a higher-level abstraction over HDFS/MR intended to
make cluster computing more convenient and accessible for less specialised programmers. You likely
noticed though that although Hive is convenient to use, it is not convenient to set up. Apache Pig
is an even more high-level way to orchestrate tasks on a HDFS/MR cluster. If Pig detects a hadoop
config it will immediately connect to that config and use it to execute its queries. Queries in pig
are made using a procedural SQL-like language called "pig latin". This language allows programmers
to easily interact with a HDFS/MR cluster and do simple analyses in a familiar, procedural way.

## Pig Examples ##

### Word Count ###

To begin, let's try another word count program (locally first(1)).
{ .annotate }

1. To run pig locally run `pig -x local`. Otherwise, pig will automatically try to connect to the
Hadoop cluster defined in `core-site.xml` and the associated config files.

```pig
--8<-- "lab3/src/word_count.pig"
```

QUESTION: By now you should be fully equipped to do this same operation on your Hadoop cluster
without the need for a walkthrough. Can you figure it out?

WARNING: if you run pig on mapreduce, you need to make sure the input file is on HDFS. Once you
connect to pig from your client node it will automatically treat the HDFS cluster filesystem as if
it were your local filesystem.

### CSV Handling ###

Two example CSVs can be found in `./data/`, `iris1.csv` and `iris2.csv`. These CSVs are 2 halves
of a single CSV dataset. As a toy example of using pig to handle CSVs, we can recombine these files
into a single dataset. To do so, run the PigLatin commands below, one by one from shell, and
observe what is contained in `d`, `e`, `f` and `G` after each dump.

QUESTION: The output of `DUMP G` can tell us a lot about how pig handles schema on the fly. Take
some time to examine and reflect upon the results you get here. What interesting things do you
notice about this output?

```pig
--8<-- "lab3/src/merge_csv.pig"
```

### Further Reading and Examples &nbsp; ###

- [PigLatin basics](http://pig.apache.org/docs/r0.17.0/basic.html#load)
- [Git script examples](https://gist.github.com/brikis98/1332818)
- [Operators example](https://techvidvan.com/tutorials/apache-pig-operators/)
- [Movie examples](https://www.wikitechy.com/tutorials/apache-pig/apache-pig-example)

## Bonus: using Pig and Hive on real big data ##

If you want a more challenging problem to tackle with what you've learned so far, we have an extra
lab walkthrough you can try that combines the use of Pig and Hive to process a real world big data
dataset. If you want to test your skills so far try
[Bonus Lab 2: Honey Roast Ham 󰾡&nbsp;󱀆&nbsp;](../bonus2.md)
