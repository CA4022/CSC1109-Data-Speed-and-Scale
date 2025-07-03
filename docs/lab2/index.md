---
title: "Lab 2: Hive"
docker_test_image: ghcr.io/amileo/csc1109-lab2:latest
test_volumes:
- host_path: ./docs/lab2/src/
  container_path: /lab/src/
  mode: ro
init_commands:
  - cp -r /lab/src/* /lab/
---

{{ "# " ~ page.meta.title ~ " #" }}

This lab covers material from week 3. During it we will deploy a HIVE node and practice with
simple queries and file operations on external tables. HIVE can either run on top of a working
HDFS/MapReduce cluster, or in local mode (useful for debugging).

INFO: Hive requires an external database called the "Metastore", in which metadata is stored. This
metastore can be either an SQL database or an Apache Derby database. In this example, we will be
using a Derby database because it is better integrated with Hive but you can use an SQL db in your
own experiments if you wish. More information on how to do this is available at the [Apache HIVE
DockerHub Page](https://hub.docker.com/r/apache/hive)

To download the container for this lab, run the following command:

```sh
docker run \
    --privileged \
    --hostname lab2 \
    -p 9870:9870 \
    -p 10000:10000 \
    -p 10002:10002 \
    -it {{ page.meta.docker_test_image }}
```

INFO: Adding a Hive server to our Hadoop cluster requires us to bootstrap a few directories in our
HDFS and add some xml files to configure the hive nodes appropriately. This is not a difficult
process but is important to be aware of! You can see how this is done by examining the changes to
the `docker-compose.yaml` file and `config` directories between Lab 1 and this lab.

Once inside the lab container, you can deploy the cluster for this lab by running:

```sh
docker compose up -d
```

## Connecting to the Hive ##

As with most operations on a HPC cluster, it is good practice to connect to a specific client node
instead of directly to a server node. To connect to the client node run:

```sh
docker compose exec -it client bash
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

---

- Bootstrap locations used to store files on HDFS (you need to make sure hadoop is running!)

  - Create warehouse folder under hive and provide permission:

    `$ bin/hdfs dfs -mkdir -p /user/hive/warehouse`

    `$ bin/hdfs dfs -chmod g+w /user/hive/warehouse`

  - Create tmp folder in root and provide permission

    `$ bin/hdfs dfs -mkdir -p /tmp` should already exist from hadoop installation

    `$ bin/hdfs dfs -chmod g+w /tmp` should already have the right access rights from hadoop
    installation

    `$ bin/hdfs dfs -mkdir -p /tmp/hive`

    `$ bin/hdfs dfs -chmod 777 /tmp/hive`

- Run the shell (of the three modes to run HIVE, we will use command line)

  - `$ $HIVE_HOME/bin/hive`

- Execute Hive queries (see example file in this repository and links in Hive Examples and Tutorials below)

- Exit hive shell

  - `$ >exit;`

- Where are tables stored? (you need to clean this up if you want to recreate the same table)

  - `$ hdfs dfs -ls /user/hive/warehouse/table-name`

### Hive in local mode ###

You can run hive in local mode. First make sure you have the right permission and directories
locally (create such directories if they do not exist yet):

- `$ sudo chmod 777 /tmp/hive/*`
- `$ mkdir /tmp/hive/warehouse`
- `$ sudo chmod g+w /tmp/hive/warehouse`

Then you need to change some configuration variables. I suggest not to change hive-site.xml or
core-site.xml properties, but instead modify the some of the necessary variables for hive local
execution before launching the hive shell for a specific terminal session (with EXPORT) and to set
other variables for a specific hive session (with SET command) as below:

- Use the EXPORT command to set HIVE_OPTS for a session (note that to unset this for a
  pseudo-distributed execution of HIVE you need to run the command `$ unset HIVE_OPTS`):

`$ EXPORT  HIVE_OPTS='-hiveconf mapreduce.framework.name=local -hiveconf fs.defaultFS=file:///tmp -hiveconf hive.metastore.warehouse.dir=file:///tmp/hive/warehouse -hiveconf hive.exec.mode.local.auto=true'`

This will will set the default warehouse dir to be /tmp/warehouse and the default file system to be
in the local folder /tmp. With the above you have also created a path on local machine for mapreduce
to work locally (note this is created in user home not in hadoop home as you write “/tmp…” and not
“tmp…”) and you override the core-site.xml setup to run on local FS as opposed to HDFS.

- Use the SET command for other variables to be set for a specific hive session (this can be done
  from within the hive shell and it is reset once you exit hive’s CLI):

<!-- can also set this by commandline: `$ hive> SET hive.exec.mode.local.auto=true; ` %(default is false) -->

- `$ hive> SET hive.exec.mode.local.auto.inputbytes.max=50000000;`

- `$ hive> SET hive.exec.mode.local.auto.input.files.max=5;`

Note that by default mapred.local.dir=/tmp/hadoop-username/mapred and this is ok. You need to make
sure mapred.local.dir points to a valid local path so the default path should be there or else you
can specify a different one

Check more info on Hive configuration at
[Getting Started with Running Hive](https://cwiki.apache.org/confluence/display/Hive/GettingStarted#GettingStarted-RunningHiveCLI)

### Hive Reference manual and Examples/Tutorials ###

- Reference manuals:

  - [Hive Data Definition Language](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL)
  - [Hive Data Manipulation Language](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DML#LanguageManualDML-HiveDataManipulationLanguage)
  - [Hive Select queries](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Select)

- Check examples to Create, Load, Query data with Hive:

  - [Simple example queries (from step 15.)](https://www.java-success.com/10-setting-getting-started-hive-mac/)
  - [More query examples](https://datapeaker.com/en/big--data/hive-queries-15-basic-hive-queries-for-data-engineers/)
  - [Hive Join examples](https://www.sparkcodehub.com/hive/mastering-hive-joins)
  - [Hive Sampling examples] ()
  - [Hive Subqueries examples] ()

- Create your own tables and load data from a .txt file you have created or downloaded, then
  practice some queries.

  - [Example: load csv file in HIVE table](https://sparkbyexamples.com/apache-hive/hive-load-csv-file-into-table/)
  - [Example: load data into tables](https://www.geeksforgeeks.org/hive-load-data-into-table/)

- You can find more query examples and SQL cheat-sheet
  [here](https://hortonworks.com/blog/hive-cheat-sheet-for-sql-users/)

- Check manual on Loop for HIVEQL basics with examples

- Additional tutorials:

  - [Hive tutorial for beginners](https://www.guru99.com/hive-tutorials.html)
  - [Hive tutorial and refresher](https://www.analyticsvidhya.com/blog/2020/12/15-basic-and-highly-used-hive-queries-that-all-data-engineers-must-know/)

### Hive errors and fixes ###

Below is a list of possible errors you might encounter when installing and running Hive, and how to
fix them.

- [Guava incompatibility error](https://phoenixnap.com/kb/install-hive-on-ubuntu)
- "Name node is in safe mode" error:
  - Check if namenode safemode is ON: `$ $HADOOP_HOME/bin/hadoop dfsadmin –safemode get`
  - If this is the case, disable it: `$ $HADOOP_HOME/bin/hadoop dfsadmin –safemode leave`
- URISyntaxException: Check the problematic string into hive-site.xml file and replace it with
  correct path
- Other troubleshooting tips
  [here](https://kb.databricks.com/metastore/hive-metastore-troubleshooting.html)
