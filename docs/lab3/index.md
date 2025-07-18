---
title: "Lab 3: Pig"
docker_test_image: ghcr.io/amileo/csc1109-lab3:latest
test_volumes:
- host_path: ./docs/lab3/src/
  container_path: /lab/src/
  mode: ro
init_commands:
  - cp -r /lab/src/* /lab/
---

{{ "# " ~ page.meta.title ~ " #" }}

This lab covers the basics of Apache Pig with examples.

To download the container for this lab, run the following command:

```sh
docker run --privileged --hostname lab3 -p 9870:9870 -p 19888:19888 -it {{ page.meta.docker_test_image }}
```

NOTE: If you look at the `docker-compose.yaml` for this lab, our usual HDFS cluster has an added
`historyserver` node this time. This node serves to log statistics about MapReduce jobs, which pig
uses to report the results of jobs.

## Pig Examples 󱀆&nbsp; ##

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

WARNING: if you run pig on mapreduce, you need to make sure the input file is on HDFS, e.g: using
`hdfs://namenode:9870/<path_to_input_file>`

### CSV Handling ###

Two example CSVs can be found in `./data/`, `iris1.csv` and `iris2.csv`. These CSVs are 2 halves
of a single CSV dataset. As a toy example of using pig to handle CSVs, we can recombine these files
into a single dataset. To do so, run the PigLatin commands below, one by one from shell, and
observe what is contained in `d`, `e`, `f` and `G` after each dump.

QUESTION: The output of `DUMP G` can tell us a lot about how pig handles schema on the fly. Take
some time to examine and reflect upon the results you get here. What do you interesting things do
you notice about this output?

```pig
--8<-- "lab3/src/merge_csv.pig"
```

### Further Reading and Examples ###

- [PigLatin basics](http://pig.apache.org/docs/r0.17.0/basic.html#load)
- [Git script examples](https://gist.github.com/brikis98/1332818)
- [Operators example](https://techvidvan.com/tutorials/apache-pig-operators/)
- [Movie examples](https://www.wikitechy.com/tutorials/apache-pig/apache-pig-example)

## Bonus: using Pig and Hive on real big data ##

If you want a more challenging problem to tackle with what you've learned so far, we have an extra
lab walkthrough you can try that combines the use of Pig and Hive to process a real world big data
dataset. If you want to test your skills so far try
[Bonus Lab 2: Honey Roast Ham 󰾡&nbsp;󱀆&nbsp;](../bonus2.md)
