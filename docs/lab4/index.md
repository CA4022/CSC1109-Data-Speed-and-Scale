---
title: "Lab 4: Storm"
docker_test_image: ghcr.io/amileo/csc1109-lab4:latest
test_volumes:
- host_path: ./docs/lab4/src/
  container_path: /lab/src/
  mode: ro
init_commands:
  - cp -r /lab/src/* /lab/
---

{{ "# " ~ page.meta.title ~ " #" }}

This lab asks you to try and set up a simple Apache Storm topology.

To download the container for this lab, run the following command:

```sh
docker run --privileged --hostname lab4 -p 9870:9870 -it {{ page.meta.docker_test_image }}
```

<!--Note, maven must be installed and configured-->

# Storm: install and compile the jar files run your first topology

1. Download binary from the internet (using a mirror site)

`$ wget https://dlcdn.apache.org/storm/apache-storm-2.4.0/apache-storm-2.4.0-src.tar.gz`

2. Unzip STORM binary (in current directory, use `$ -C ~/<dirname> ` to unzip in a different directory `<dirname>` under user home folder)

`$ tar -xvzf apache-storm-2.4.0-src.tar.gz `

3. If you do not have Maven installed and configure:
  - on Unix/Linux: `$ sudo apt-get install maven`
  - on Mac: `$ brew install maven`
  - check it installed correctly: `$ mvn -version`

# Run your first Storm topology with Maven: Wordcount



1. Go into the storm-starter project within the examples folder: `$ cd examples/storm-starter`

2. Compile and build the jar files: `$ mvn clean install -DskipTests=true`
   - Note: it should take a few minutes, and you will see a lot of output with "Build Success" in the end

3. Compile the wordcount example project with maven:

- `$ mvn compile -Dstorm.topology=storm.starter.WordCountTopology -Dexec.mainClass="WordCountTopology"`

- `$ mvn compile exec:java -Dstorm.topology=storm.starter.WordCountTopology -Dexec.mainClass="WordCountTopology"`

4. Run the wordcount topology example, previously compiled, in *local* mode
  - change to storm root directory and check that your environmental variables are all set
  - `./bin/storm local ./examples/storm-starter/target/storm-starter-2.4.0.jar org.apache.storm.starter.WordCountTopology `

Let's now have a look at the details of what happened when you run the topology, where are the files and what do they look like [here](https://www.cnblogs.com/oxspirt/p/8179070.html)
<!--On a cluster: `$ bin/storm jar examples/storm-starter/target/storm-*.jar  storm.starter.ExclamationTopology`-->

## Note that to run a topology on a cluster you first need to run the cluster
Check how to deploy Storm in production in the final part of [this tutorial](https://www.cnblogs.com/oxspirt/p/8179070.html)

## Note on Maven sources and target folders
Technically, any directory that contains a pom.xml file is also a valid Maven project. A pom.xml file contains everything needed to describe your Java project.
Apart from a pom.xml file, you also need Java source code for Maven to do its magic, whenever you are calling mvn clean install. By convention:
   - Java source code is to be meant to live in the "/src/main/java" folder
   - Maven will put compiled Java classes into the "target/classes" folder
   - Maven will also build a .jar or .war file, depending on your project, that lives in the "target" folder.

Your project will look like this:
+ `$ storm-starter/src/jvm/org/apache/storm/starter/WordCountTopology.java`
+ `$ storm-starter/target/classes/org/apache/storm/starter/WordCountTopology.class` (after 'mvn compile')
+ `$ storm-starter/target/storm-starter-2.2.0.jar` (upon mvn package or mvn install)



<!-- see maven details at https://www.marcobehler.com/guides/mvn-clean-install-a-short-guide-to-maven
# Questions
1. Where does the data come from?
2. How would you modify this code to make it case-insensitive?
-->
