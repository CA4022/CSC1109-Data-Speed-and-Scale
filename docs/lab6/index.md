---
title: "Lab 6: Machine Learning with Spark"
docker_test_image: ghcr.io/amileo/csc1109-lab6:latest
test_volumes:
- host_path: ./docs/lab6/src/
  container_path: /lab/src/
  mode: ro
init_commands:
  - cp -r /lab/src/* /lab/
---

{{ "# " ~ page.meta.title ~ " #" }}

This lab will explore how we can use the experience we have built so far to develop machine
learning systems capable of processing vast amounts of data in a scalable, efficient manner. This
lab will place you in an interactive, jupyter environment with access to the full power and
capabilities of a (locally simulated, of course) Spark cluster. The documentation here will provide
some pointers and a wealth of resources for Machine Learning with Spark. Your goal for this lab
will be to implement the program outlined [below](#the-challenge). By combining the pointers and
resources here with the expertise you have built so far you should have all the tools you need at
this point to solve these big data ML problems yourself! 

To download the container for this lab, run the following command:

```sh
docker run --privileged --hostname lab6 -p 8000:8080 -p 4040:4040 -p 8000:8000 -p 8888:8888 -p 9870:9870 {{ page.meta.docker_test_image }}
```

This will automatically deploy the stack without forking it as a daemon, as we will not be working
in the CLI for this lab.

## Getting Started ##

Once the stack is deployed, it will bind the following ports on your host
machine:

- 8000: [Spark WebUI](http://localhost:8000/)
- 8888: [Jupyter Notebook](http://localhost:8888/lab)
- 9870: [Hadoop WebUI](http://localhost:9870/)

Connecting to the jupyter notebook will drop you in a full interactive coding environment from
which you can easily explore your data and test/develop your model. This environment will allow you
to interactively write code in Python, Scala, or Java. For this lab, we recommend working in
Python, however, you can choose to use whichever you are most comfortable with or any combination
of the three depending on your preferences and competences(1).
{ .annotate }

1. You could also use `R` if you want, but if you do please bare in mind: you're on your own with
that!

Once you have opened a notebook, you can create a Spark session to begin working interactively.
Once you have a session, you can work interactively as you would in any other Spark shell.

<div class="annotate" markdown>
=== "&nbsp; Python"

    ```python
    from pyspark.sql import SparkSession

    spark = (
        SparkSession.builder
            .master("spark://spark-master:7077") # (1)
            .appName("Spark Python Notebook")
            .getOrCreate()
    )
    sc = spark.sparkContext
    ```

=== "&nbsp; Scala"

    ```scala
    import $ivy.`org.apache.spark::spark-sql:4.0.0` // (2)

    import org.apache.spark.sql.SparkSession

    val spark = SparkSession.builder()
        .master("spark://spark-master:7077") // (3)
        .appName("Spark Scala Notebook")
        .getOrCreate()

    val sc = spark.sparkContext

    sc.setLogLevel("WARN") // (4)
    ```

=== "&nbsp; Java"

    ```java
    %dependency /add org.apache.spark:spark-sql_2.13:4.0.0 // (5)
    %dependency /resolve

    import org.apache.spark.sql.SparkSession;
    import org.apache.spark.api.java.JavaSparkContext;

    SparkSession spark = SparkSession.builder()
        .appName("Spark Java Notebook")
        .master("spark://spark-master:7077") // (6)
        .getOrCreate();

    JavaSparkContext sc = new JavaSparkContext(spark.sparkContext());

    sc.setLogLevel("WARN"); // (7)
    ```

</div>

1. You can also run locally, but here we want to use our Spark cluster.
2. When using the `almond` jupyter kernel for Scala, we use `ivy` to install dependencies.
3. You can also run locally, but here we want to use our Spark cluster.
4. If we don't set the log level to "WARN" we will get a lot of log outputs in our cell outputs.
5. The `rapaio-java-kernel` for jupyter notebook includes `minimaven` and this convenient
    `%dependency` magic that can be used to add dependencies to your notebook.
6. You can also run locally, but here we want to use our Spark cluster.
7. If we don't set the log level to "WARN" we will get a lot of log outputs in our cell outputs.

For this lab, you will be given 2 challenges to complete that require you to train ML models on
your distributed Spark cluster. The data you will be analysing for these challenges is available on
the brilliant open dataset repository [OpenML](https://openml.org). These datasets all have a name,
an ID, and a version and can be downloaded via a simple REST API or an one of the many wrapper
libraries in your language of choice.

=== "&nbsp; Python"

    ```python
    from sklearn import datasets as sklds
    from pyspark.sql import SparkSession

    spark = None
    try:
        spark = (
            SparkSession.builder
                .master("spark://spark-master:7077")
                .appName("Dataset to HDFS")
                .getOrCreate()
        )
        ds = sklds.fetch_openml(<dataset_name>, version=<dataset_version>)
        df = ds["data"]

        spark_df = spark.createDataFrame(df)
        hdfs_path = 'hdfs://namenode/<output_path>'
        spark_df.write.mode('overwrite').parquet(hdfs_path)
    except Exception as e:
        raise RuntimeError("Something went wrong while writing to HDFS") from e
    finally:
        if spark is not None:
            spark.stop()
    ```

    `ds` will be a dict containing the data and metadata. You can peruse this metadata at your
    leisure. When you are ready to move the dataset to the hadoop cluster you can directly dump the
    "data" dataframe using `pandas`' `pd.DataFrames.to_csv` method.


=== "&nbsp; Scala"

    ```scala
    import $ivy.`org.openml:openml-java:0.10.0`

    import org.apache.spark.sql.{SparkSession, Row}
    import org.apache.spark.sql.types._
    import org.openml.apiconnector.api.ApiClient
    import scala.util.control.NonFatal

    var spark: SparkSession = null
    try {
        spark = SparkSession.builder
            .master("spark://spark-master:7077")
            .appName("Dataset to HDFS")
            .getOrCreate()
        val sc = spark.sparkContext

        val apiClient = new ApiClient()
        val datasetId = <dataset_id>
        val dsd = apiClient.dataGet(datasetId)
        val url = dsd.getUrl()

        val schema = StructType(Array(
            StructField(<field1_name>, <field1_type>, true),
            StructField(<field2_name>, <field2_type>, true),
            ...
        ))

        val dataLines = sc.textFile(url)
            .filter(line => !line.startsWith("@") && !line.trim.isEmpty)

        // Convert lines to Rows
        val rowRDD = dataLines.flatMap { line =>
            val attr = line.split(",")
            try {
                Some(Row(
                    attr(0).<field1_type_conversion>,
                    attr(1).<field2_type_conversion>,
                    ...
                ))
            } catch {
                case _: Exception => None // Skip lines that fail to parse
            }
        }

        val sparkDf = spark.createDataFrame(rowRDD, schema)
        val hdfsPath = "hdfs://namenode/<output_path>"
        sparkDf.write.mode("overwrite").parquet(hdfsPath)
        println(s"Successfully wrote dataframe to $hdfsPath")

    } catch {
        case NonFatal(e) =>
            println(s"An error occurred: ${e.getMessage}")
            e.printStackTrace()
    } finally {
        if (spark != null) {
            spark.stop()
        }
    }
    ```

=== "&nbsp; Java"

    ```java
    %dependency /add org.openml:openml-java:0.10.0
    %dependency /resolve

    import org.apache.spark.api.java.JavaRDD;
    import org.apache.spark.api.java.JavaSparkContext;
    import org.apache.spark.sql.Dataset;
    import org.apache.spark.sql.Row;
    import org.apache.spark.sql.RowFactory;
    import org.apache.spark.sql.SparkSession;
    import org.apache.spark.sql.types.DataTypes;
    import org.apache.spark.sql.types.StructField;
    import org.apache.spark.sql.types.StructType;
    import org.openml.apiconnector.api.ApiClient;
    import org.openml.apiconnector.xml.DataSetDescription;
    import java.util.Objects;

    SparkSession spark = null;
    try {
        spark = SparkSession.builder()
                .master("spark://spark-master:7077")
                .appName("Dataset to HDFS with OpenML")
                .getOrCreate();

        JavaSparkContext sc = new JavaSparkContext(spark.sparkContext());

        ApiClient apiClient = new ApiClient();
        int datasetId = <dataset_id>;
        DataSetDescription dsd = apiClient.dataGet(datasetId);
        String url = dsd.getUrl();

        StructType schema = DataTypes.createStructType(new StructField[]{
            DataTypes.createStructField(<field1_name>, <field1_type>, true),
            DataTypes.createStructField(<field2_name>, <field2_type>, true),
            ...
        });

        JavaRDD<String> dataLines = sc.textFile(url)
                .filter(line -> !line.startsWith("@") && !line.trim().isEmpty());

        JavaRDD<Row> rowRDD = dataLines.map(line -> {
            String[] attributes = line.split(",");
            try {
                return RowFactory.create(
                    <field1_type_conversion>(attributes[0]),
                    <field2_type_conversion>(attributes[0]),
                    ...
                );
            } catch (Exception e) {
                return null;
            }
        }).filter(Objects::nonNull);

        Dataset<Row> sparkDf = spark.createDataFrame(rowRDD, schema);
        String hdfsPath = "hdfs://namenode/<output_path>";
        sparkDf.write().mode("overwrite").parquet(hdfsPath);
        System.out.println("Successfully wrote dataframe to " + hdfsPath);

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (spark != null) {
            spark.stop();
        }
    }
    ```

=== "󰒲&nbsp; REST API"

    ```sh
    curl https://www.openml.org/api/v1/json/data/<dataset_id>
    ```

    The returned JSON string includes all the metadata for the dataset, and a download url at the
    `data_set_description.url` attribute. Once downloaded, the file will need to be manually moved
    to the Hadoop cluster.

## The Challenges ##

### Challenge 1: Spam Filter 󰗩&nbsp;

Challenge 1 will be to create a distributed system capable of identifying spam emails.

???+ DATASET

    <span style="font-size: 1.5em;">[**Enron Emails**](https://openml.org/d/41466)</span>

    Multi-label dataset. The UC Berkeley enron4 dataset represents a subset of the original enron5
    dataset and consists of 1684 cases of emails with 21 labels and 1001 predictor variables.

    - Id: 41466
    - Name: enron
    - Version: 3
    - Notes: Derived from a dataset of thousands of emails made public during the famous "Enron
    scandal" investigations.

### Challenge 2: Movie Recommender 󱄤&nbsp;

Challenge 2 will be to create a distributed system capable of recommending movies.

???+ DATASET

    <span style="font-size: 1.5em;">[**IMDB Movies**](https://openml.org/d/43603)</span>

    Context The IMDB Movies Dataset contains information about 5834 movies. Information about these
    movies was scraped from imdb for purpose of creating a movie recommendation model. The data was
    preprocessed and cleaned to be ready for machine learning applications.

    - Id: 43603
    - Name: IMDB_movie_1972-2019
    - Version: 1
    - Notes: Derived from reviews on the film review aggregator website "imdb.com"

## Further Reading and Examples &nbsp; ##

### ML in Spark ###

You can read the main ML library documentation [here](https://spark.apache.org/docs/latest/ml-guide.html)

- spark.ml package is now the primary API (data frame based api)
- spark.mllib package is now in maintenance mode (RDD-based API) available
[here](https://spark.apache.org/docs/latest/mllib-guide.html)

Note: SparkML (on DataFrames) supports ML pipelines and should therefore be your library of
choice for ML on Spark (e.g. in your assignment).

Warning: While you can do ML with Spark in any of the languages we have covered, we do think it is
important to stress: **we recommend using Python for this! There is 

Further links:

- Python
    - [Connect Jupyter Notebook to a Spark Cluster](https://www.bmc.com/blogs/jupyter-notebooks-apache-spark/)
    - [Pyspark ml modules](https://spark.apache.org/docs/latest/api/python/reference/pyspark.ml.html)
- Scala/Java/Python
    - [Machine Learning with MLib](https://www.tutorialkart.com/apache-spark/apache-spark-mllib-scalable-machine-learning-library/)

You can start by running some of the examples available in `$SPARK_HOME/examples/src/main/python/ml/`
The corresponding code is also illustrated in the [MLlib manual](https://spark.apache.org/docs/latest/ml-guide.html)

### Statistical Correlation ###

The example is illustrated [here](https://spark.apache.org/docs/latest/ml-statistics.html#correlation) and contained in `correlation_example.py`
- start spark master and worker as seen in previous labs (if not running already)
- submit the task to your spark server
    - `$ spark-submit --master spark://spark-master:7077 examples/src/main/python/ml/correlation_example.py`
- check in your output the spearman's and pearson's correlation matrix for the input vectors

### K-Means clustering ###

The example is illustrated [here](https://spark.apache.org/docs/latest/ml-clustering.html#k-means) and contained in `kmeans_example.py`
- start spark master and worker as seen in previous labs (if not running already)
- submit the task to your spark server
    - `$ spark-submit --master spark://spark-master:7077 examples/src/main/python/ml/kmeans_example.py`
- check output

### Feature Extraction, Transformation and Selection ###

When processing documents, it is very common that we need to transform text into numeric
vectors/matrices, because this is what ML algorithms can actually understand. This is an entire
field of ML unto itself, known as NLP. Luckily, for relatively common tasks such as our goals for
this lab, there are many, many existing NLP algorithms we can use to extract and transform relevant
features we can use in our ML model.

[This section](https://spark.apache.org/docs/latest/ml-features.html) of the MLlib main guide
provides several mechanisms to extract features from raw data (e.g. TF-IDF for vectorization of
text features), transform features (e.g. n-grams used for shingling, remove stop words, tokenize,
...), select a subset of relevant features (e.g. from a vector column), and hashing (including LSH,
min-hash seen in item similarity and used for clustering and recommendation).

Note: You are likely to have a mix of data types (RDDs and DataFrames) in complex projects. When
interacting with data remember to confirm what data structure is used to wrap it, as this will
determine what functions you can use to interact with it.

Try and run the following examples from the [spark documentation](https://spark.apache.org/docs/latest/ml-features.html):
- Word2Vec or CountVectoriser
- StopWordsRemover (try it with a different language)
- n-grams

WARNING: The order of operations with some of these algorithms is essential, as some take the
output of a previous transformation as input (e.g. tokenizer/stopwordsremover/n-grams).

### ML Pipelines ###

- Generally high-level APIs working on DataFrames
- Most ML work focuses on coordinating a pipeline, only writing low-level custom code when required
- Example: Spam email detection (modified from
[pipeline_example.py](https://spark.apache.org/docs/latest/ml-pipeline.html#example-pipeline))
    - Python code as shown below:
    ```python title="spam_ham.py"
    --8<-- "lab6/src/spam_ham.py"
    ```
    - Note that we omit reading the data from the file for simplicity. Instead, we're hardcoding
    the strings for clarity.
    - Look into the different steps:
        - Prepare training documents
        - Configure pipeline
        - Fit the model with training documents (estimator)
        - Prepare test documents
        - Make prediction on test documents(transformer)
    - Use spark-submit to run spam-ham.py

QUESTION: how would you modify the code to do sentiment analysis, using logistic regression?

###  Classification/Clustering examples ###

You can experiment with some of the provided examples of
[Classification](https://spark.apache.org/docs/latest/ml-classification-regression.html) and
[Clustering](https://spark.apache.org/docs/latest/ml-clustering.html) in the Spark Documentation.

### Recommender Systems example and resources ###

The Spark documentation recommendation is based on ALS matrix factorisation algorithms. Some
examples of how to build a RecSys based on Collaborative filtering with ALS in PySpark include:

- [Movie recommender](https://spark.apache.org/docs/latest/ml-collaborative-filtering.html)
- [Book recommender](https://towardsdatascience.com/building-a-recommendation-engine-to-recommend-books-in-spark-f09334d47d67)
