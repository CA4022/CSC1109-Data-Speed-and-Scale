Cluster includes:

- Spark (spark-shell, pyspark, beeline, sparkR)
- Hive (hive, beeline)
- Pig (pig)

File moved to /test/lab.md on HDFS cluster.
Testing shows:

- spark-shell:

    ```sh
    scala> val data = sc.textFile("hdfs://namenode/test/lab.md")
    val data: org.apache.spark.rdd.RDD[String] = hdfs://namenode/test/lab.md MapPartitionsRDD[1] at textFile at <console>:1

    scala> data.take(20).foreach(println)
    ## CSC1109 Sandbox

    Welcome to the sandbox for the CSC1109 labs! This sandbox includes a full, integrated data science
    stack that makes all of the various technologies we will be learning about during the semester of
    lab work. These technologies include:

    - A hadoop cluster
    - A spark cluster
    - A hive cluster
    - A pig interpreter

    All configured to be interoperable and usable as part of a single, interactive notebook
    environment.

    scala> data.saveAsTextFile("hdfs://namenode/test/output/spark")

    scala> :q
    (base) jovyan@2178d7ef3ff7:/lab$ hdfs dfs -cat /test/output/spark/*
    ## CSC1109 Sandbox

    Welcome to the sandbox for the CSC1109 labs! This sandbox includes a full, integrated data science
    stack that makes all of the various technologies we will be learning about during the semester of
    lab work. These technologies include:

    - A hadoop cluster
    - A spark cluster
    - A hive cluster
    - A pig interpreter

    All configured to be interoperable and usable as part of a single, interactive notebook
    environment.
    ```

    NOTE: Spark MUST access HDFS via Web API (port 8020) rather than RPC (port 9870)

- beeline:

    Failing because postgresql driver wasn't in library.

- pig:

    Not working currently in spark mode (only local)
