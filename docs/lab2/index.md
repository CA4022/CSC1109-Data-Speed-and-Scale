---
title: "Lab 2: Hive"
docker_image: ghcr.io/amileo/csc1109-lab2:latest
volumes:
- host_path: ./docs/lab2/src/
  container_path: /lab/src/
  mode: ro
init_commands:
  - cp -r /lab/src/* /lab/
---

{{ "# " ~ page.meta.title ~ " #" }}

This lab covers material from week 3. During it we will deploy a Hive cluster and practice with
simple queries and file operations on external tables. Hive can either run on top of a working
HDFS/MapReduce cluster, or in local mode (useful for debugging). In this lab, as we are here
to demonstrate and get hands-on experience with distributed computing, we will be in HDFS/MR mode.

To download the container for this lab and run it, execute the following commands:

```sh
docker pull {{ page.meta.docker_test_image }}
docker run --privileged --hostname lab2 -p 9870:9870 -p 10000:10000 -p 10002:10002 -it {{ page.meta.docker_image }}
```

INFO: Adding a Hive server to our Hadoop cluster requires us to bootstrap a few directories in our
HDFS and add some xml files to configure the hive nodes appropriately. This is not a difficult
process but is important to be aware of! You can see how this is done by examining the changes to
the `docker-compose.yaml` file and `config` directories between Lab 1 and this lab.

Once inside the lab container, you can deploy the cluster for this lab by running:

```sh { .test-block #ghcr.io/amileo/csc1109-lab2:latest }
docker compose up -d
```

## Anatomy of a Hive cluster ##

If you examine the stack we just deployed, you will see the familiar structure of our
HDFS/MapReduce cluster from lab 1. However, you will also see 3 new nodes that comprise the Hive
query engine:

=== "Node List"
    - lab-hiveserver-1
    - lab-metastore-1
    - lab-postgres-1

=== "Cluster Topology Diagram"
    ```mermaid
    --8<-- "lab2/topology.mmd"
    ```

### Hiveserver ###

The `hiveserver` node houses the query engine and interpreter for the hive. It also is responsible
for other elements of client interaction such as authentication. When we query our HDFS cluster,
the `hiveserver` will take care of converting those queries to MapReduce code and executing it.

### Metastore ###

The `metastore` handles the state management for the hive. When the `hiveserver` creates tables,
assigns variables, or otherwise changes state, the `metastore` stores them. This also means it is
responsible for retrieving the state, acting as a single source of truth for the entire hive. Of
course, for big data applications this state metadata can become quite large, so the `metastore`
needs some way of storing the state it manages on the disk instead of in RAM.

### MetastoreDB ###

The `metastoredb` is simply a database that acts as the storage backend for the `metastore`. In
development, this backend database will often be Apache derby, as a lightweight, transparent, debug
database. However, in production (as in this lab), this will usually be a PostgreSQL database (hence
the container name `postgres`.

The metastore can also use most common databases as its backend including MySQL, MariaDB, Oracle
SQL, and Microsoft SQL. For even more distributed setups, it also supports cloud SQL databases (e.g:
Amazon RDS, Google Cloud SQL, or Azure SQL), in addition to distributed SQL databases like TiDB.

## Connecting to the Hive 󱃎&nbsp; ##

As with most operations on a HPC cluster, it is good practice to connect to a specific client node
instead of directly to a server node. To connect to the client node run:

```sh
docker compose exec -it client default_shell
```

Once inside the client container, we need to open the REPL for running Hive commands. This REPL is
called "beeline", and can be started by running the `beeline` command. On the beeline REPL, we can
connect to a client with the `!connect` command. To connect to the `hiveserver` node, run the
command:

```sql
!connect jdbc:hive2://hiveserver:10000
```

This will prompt the user to enter a username and password to connect to the Hive. For the purposes
of this demonstration, the username and password here have both been set to "hive".

## Sending Out Worker Bees 󰾢&nbsp; - Querying the Hive ###

Once we are deployed and connected to our hive cluster, running distributed queries is as simple
as running some basic SQL commands. The lab environment includes a test file we can use to quickly
demonstrate this at `data/iris.csv`(1). First though, we must move the file to our HDFS cluster.
{ .annotate }

1. The iris dataset is a commonly used csv table for demonstrating data analysis tools. In data
science, it could be described as the "Hello World" of datasets.

```sh { .test-block #ghcr.io/amileo/csc1109-lab2:latest }
hdfs dfs -mkdir -p /user/hive/data/
hdfs dfs -put /lab/data/iris.csv /user/hive/iris.csv
```

Then, we can simply create a table, and read in that file.

```sql
--8<-- "lab2/src/create_table.sql"
```

This moves the csv file to the hive cluster's data warehouse and parses it as a table. Then, if we
view the head of the table, we can see the data we expect.

```sql
--8<-- "lab2/src/create_table.sql"
```

At this point we have created a SQL table containing our dataset, that is decentrally stored across
a number of nodes and where queries on that table will run across the entire cluster. From here, we
can treat it as any other common, familiar SQL table while reaping the benefits of running on a
HDFS/MapReduce cluster.

## Further Reading & Examples &nbsp; ##

At this point, we encourage further, independent exploration of hive. This platform provides most
of the capabilities of a normal SQL engine backed by the big data processing capability of a
HDFS/MapReduce cluster, so it should provide a familiar setting in which to experiment with cluster
computations.

### Reference manuals ###

The most important pages in the Apache Hive documentation an be found here:

- [Getting Started with Running Hive](https://cwiki.apache.org/confluence/display/Hive/GettingStarted#GettingStarted-RunningHiveCLI)
- [Hive Data Definition Language](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL)
- [Hive Data Manipulation Language](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DML#LanguageManualDML-HiveDataManipulationLanguage)
- [Hive Select queries](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Select)

### Examples ###

Examples of how to create, load, and query data with Hive:

- [Simple example queries (from step 15.)](https://www.java-success.com/10-setting-getting-started-hive-mac/)
- [More query examples](https://datapeaker.com/en/big--data/hive-queries-15-basic-hive-queries-for-data-engineers/)
- [Hive Join examples](https://www.sparkcodehub.com/hive/mastering-hive-joins)
- [Hive Sampling examples](https://dwgeek.com/hive-table-sampling-concept-and-example.html/)
- [Hive Subqueries examples](https://dwgeek.com/apache-hive-correlated-subquery-and-its-restrictions.html/)

Create your own tables and load data from a file you have created or downloaded, then
practice some queries.

- [Example: load csv file in Hive table](https://sparkbyexamples.com/apache-hive/hive-load-csv-file-into-table/)
- [Example: load data into tables](https://www.geeksforgeeks.org/hive-load-data-into-table/)

You can find more query examples and SQL cheat-sheet
[here](https://hortonworks.com/blog/hive-cheat-sheet-for-sql-users/)

Check manual on Loop for HiveQL basics with examples.

### Additional tutorials ###

- [Hive tutorial for beginners](https://www.guru99.com/hive-tutorials.html)
- [Hive tutorial and refresher](https://www.analyticsvidhya.com/blog/2020/12/15-basic-and-highly-used-hive-queries-that-all-data-engineers-must-know/)
