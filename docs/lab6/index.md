---
title: "Lab 6: Machine Learning with Spark"
docker_image: ghcr.io/ca4022/csc1109-lab6:latest
---

{{ "# " ~ page.meta.title ~ " #" }}

This lab will explore how we can use the experience we have built so far to develop machine
learning systems capable of processing vast amounts of data in a scalable, efficient manner. This
lab will place you in an interactive, jupyter environment with access to the full power and
capabilities of a (locally simulated, of course) Spark cluster. The documentation here will provide
some pointers and a wealth of resources for Machine Learning with Spark. Your goal for this lab
will be to implement the systems outlined [below](#the-challenges). By combining the pointers and
resources here with the expertise you have built so far you should have all the tools you need at
this point to solve these big data ML problems yourself! 

To download the container for this lab and run it, execute the following commands:

```sh
docker pull {{ page.meta.docker_image }}
docker run --rm --privileged --hostname lab6 -v lab6:/lab/ -v lab_cache:/run/containers/ -p 8000:8080 -p 4040:4040 -p 8000:8000 -p 8888:8888 -p 9870:9870 {{ page.meta.docker_image }}
```

This will automatically deploy the stack without forking it as a daemon, as we will not be working
in the CLI for this lab.

## Getting Started ##

Once the stack is deployed, it will bind the following ports on your host
machine:

- 8000: [Spark WebUI](http://0.0.0.0:8000/)
- 8888: [Jupyter Notebook](http://0.0.0.0:8888/lab)
- 9870: [Hadoop WebUI](http://0.0.0.0:9870/)

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

> TIP: Remember, you can always download a library from a package repository to add packages you
> want to use.
>
> === "&nbsp; Python (&nbsp; [Conda](https://anaconda.org))"
>     ```
>     !mamba install -y <package>
>     ```
>
> === "&nbsp; Python (&nbsp; [PyPI](https://pypi.org))"
>     ```
>     !pip install -y <package>
>     ```
>
> === "&nbsp; Scala (&nbsp; [Maven](https://search.maven.org))"
>     ```
>     import $ivy.`<package>`
>     ```
>
> === "&nbsp; Java (&nbsp; [Maven](https://search.maven.org))"
>     ```
>     %dependency /add <package>
>     ```

For this lab, you will be given 2 challenges to complete that require you to train ML models on
your distributed Spark cluster. The data you will be analysing for these challenges is available on
the brilliant open dataset repository [OpenML](https://openml.org). These datasets all have a name,
an ID, and a version number, and can be downloaded via a simple REST API or via one of the many
wrapper libraries in your language of choice. They also provide a variety of data formats, but
*all* of their datasets are accessible in the form of an Apache Parquet table by requirement. This
is great for us, as Parquet tables are extremely widely supported in the HPC ecosystem, include
useful metadata like datatypes, and are designed for optimal read speeds and distributed access.
So, we can just keep it simple and stream these Parquet files directly onto our Hadoop cluster.


=== "󰒲&nbsp; REST API"

    ```bash
    wget -O $(curl -s 'https://www.openml.org/api/v1/json/data/<dataset_id>' | jq -r '.data_set_description.parquet_url') | hdfs dfs -put - <output_path>
    ```

    This command just curls the dataset metadata from the openml REST API, parses it with jq to
    find the `parquet_url`, then streams the parquet table from the download link directly onto the
    Hadoop cluster.

=== "&nbsp; Python"

    ```python
    import requests
    import fsspec

    dataset_id = 61
    output_path = "/iris.pq"

    api_url = f"https://www.openml.org/api/v1/json/data/{dataset_id}"
    print(f"Fetching metadata from: {api_url}")
    api_response = requests.get(api_url, timeout=30)
    api_response.raise_for_status()

    print("Parsing API response for Parquet URL...")
    metadata = api_response.json()
    parquet_url = metadata['data_set_description']['parquet_url']
    assert parquet_url

    print(f"Found Parquet URL: {parquet_url}")

    fs = fsspec.filesystem("hdfs", host="namenode")

    print(f"Streaming data to HDFS path: {output_path}")
    with requests.get(parquet_url, stream=True) as r, fs.open(output_path, "wb") as f:
        r.raise_for_status()
        written = sum(f.write(chunk) for chunk in r.iter_content(chunk_size=8192))
        print(f"Successfully streamed {written} bytes to HDFS.")
    ```

    `ds` will be a dict containing the data and metadata. You can peruse this metadata at your
    leisure. When you are ready to move the dataset to the hadoop cluster you can directly dump the
    "data" dataframe using `pandas`' `pd.DataFrames.to_csv` method.


=== "&nbsp; Scala"

    ```scala
    import $ivy.`com.fasterxml.jackson.core:jackson-databind:2.13.4`
    import $ivy.`org.apache.hadoop:hadoop-client:3.4.1`

    import com.fasterxml.jackson.databind.JsonNode
    import com.fasterxml.jackson.databind.ObjectMapper
    import org.apache.hadoop.conf.Configuration
    import org.apache.hadoop.fs.{FileSystem, Path}
    import java.io.{InputStream, OutputStream}
    import java.net.URI
    import java.net.URL
    import java.net.http.{HttpClient, HttpRequest, HttpResponse}

    val datasetId = <dataset_id>
    val hdfsOutputPathStr = "hdfs://namenode/<output_path>"

    val apiUrl = s"https://www.openml.org/api/v1/json/data/$datasetId"
    println(s"Fetching metadata from: $apiUrl")

    val httpClient = HttpClient.newHttpClient()
    val apiRequest = HttpRequest.newBuilder()
          .uri(URI.create(apiUrl))
          .build()

    val apiResponse = httpClient.send(apiRequest, HttpResponse.BodyHandlers.ofString())

    if (apiResponse.statusCode() != 200) {
        throw new RuntimeException(s"Failed to fetch metadata. Status code: ${apiResponse.statusCode()}")
    }

    val mapper = new ObjectMapper()
    val rootNode = mapper.readTree(apiResponse.body())
    val parquetUrl = rootNode.path("data_set_description").path("parquet_url").asText()

    if (parquetUrl == null || parquetUrl.isEmpty) {
        throw new RuntimeException("Could not find 'parquet_url' in the API response.")
    }
    println(s"Found Parquet URL: $parquetUrl")

    val hdfsConf = new Configuration()
    hdfsConf.addResource(new Path("/lab/config/core-site.xml"))
    hdfsConf.addResource(new Path("/lab/config/hdfs-site.xml"))

    val hdfsOutputPath = new Path(hdfsOutputPathStr)
    val fs = FileSystem.get(hdfsConf)

    var in: InputStream = null
    var out: OutputStream = null

    println(s"Streaming to HDFS path: $hdfsOutputPath")
    try {
        in = new URL(parquetUrl).openStream()
        out = fs.create(hdfsOutputPath, true)

        val bytesTransferred = in.transferTo(out)
        println(s"Successfully streamed $bytesTransferred bytes to HDFS.")
    } catch {
        case e: Exception => println(s"An error occurred during streaming: ${e.getMessage}")
    } finally {
        if (in != null) in.close()
        if (out != null) out.close()
        if (fs != null) fs.close()
        println("HDFS connection closed.")
    }
    ```

=== "&nbsp; Java"

    ```java
    %dependency /add com.fasterxml.jackson.core:jackson-databind:2.19.2
    %dependency /add org.apache.hadoop:hadoop-client:3.4.1
    %dependency /resolve

    ---

    import com.fasterxml.jackson.databind.JsonNode;
    import com.fasterxml.jackson.databind.ObjectMapper;
    import org.apache.hadoop.conf.Configuration;
    import org.apache.hadoop.fs.FileSystem;
    import org.apache.hadoop.fs.Path;

    import java.io.InputStream;
    import java.io.OutputStream;
    import java.net.URI;
    import java.net.URL;
    import java.net.http.HttpClient;
    import java.net.http.HttpRequest;
    import java.net.http.HttpResponse;


    Integer datasetId = <dataset_id>;
    String hdfsOutputPathStr = "hdfs://namenode/<output_path>.pq";

    String apiUrl = "https://www.openml.org/api/v1/json/data/" + datasetId.toString();
    System.out.println("Fetching metadata from: " + apiUrl);

    HttpClient httpClient = HttpClient.newHttpClient();
    HttpRequest apiRequest = HttpRequest.newBuilder()
            .uri(URI.create(apiUrl))
            .build();

    HttpResponse<String> apiResponse = httpClient.send(apiRequest, HttpResponse.BodyHandlers.ofString());

    if (apiResponse.statusCode() != 200) {
        throw new RuntimeException("Failed to fetch metadata. Status code: " + apiResponse.statusCode());
    }

    ObjectMapper mapper = new ObjectMapper();
    JsonNode rootNode = mapper.readTree(apiResponse.body());
    String parquetUrl = rootNode.path("data_set_description").path("parquet_url").asText();

    if (parquetUrl.isEmpty()) {
        throw new RuntimeException("Could not find 'parquet_url' in the API response.");
    }
    System.out.println("Found Parquet URL: " + parquetUrl);

    Configuration hdfsConf = new Configuration();
    hdfsConf.addResource(new Path("/lab/config/core-site.xml"));
    hdfsConf.addResource(new Path("/lab/config/hdfs-site.xml"));

    Path hdfsOutputPath = new Path(hdfsOutputPathStr);
    FileSystem fs = FileSystem.get(hdfsConf);

    System.out.println("Streaming to HDFS path: " + hdfsOutputPath);

    try (InputStream in = new URL(parquetUrl).openStream();
        OutputStream out = fs.create(hdfsOutputPath, true)) {

        long bytesTransferred = in.transferTo(out);
        System.out.println("Successfully streamed " + bytesTransferred + " bytes to HDFS.");
    }
    fs.close();
    ```

WARNING: All of these methods should work, and some of them are good starting points for building
complex, automated, dynamic data pipelines. However, sometimes simple is best. I have found in
testing that, sometimes, the repeated API calls from some of these code snippets can trigger
OpenML's (understandably) aggressive rate limiting protections. If you find one of these isn't
working reliably: using your trusty terminal and the direct, no-nonsense REST API calls is best.

## The Challenges ##

### Challenge 1: Phishing Filter 󰗩&nbsp;

Challenge 1 will be to create a distributed system capable of identifying phishing emails.

???+ DATASET

    <span style="font-size: 1.5em;">[**Phishing Email Dataset**](https://openml.org/d/46099)</span>

    The dataset named "phishing_email.csv" comprises email contents that have been classified into
    phishing or legitimate categories. Each row in the dataset is an email entry, containing two
    fields: text_combined and label. The text_combined field holds the entire content of an email,
    which may include the subject, body, and any embedded URLs, while the label fields classify the
    email as phishing (1) or legitimate (0).

    - Id: 46099
    - Name: Phishing_Email_Dataset
    - Version: 1
    - Notes: A meta-dataset, created by aggregating numerous other datasets such as the famous
        "Enron" dataset

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

>? TIP: When you get these systems working, you **could** try deploying them to the cloud similar to
> the challenge posed all the way back in Lab 1 when we directed you to [Bonus Lab 1](../bonus1.md).
> At this point, you will have (for all intents and purposes) deployed your own content
> recommendation infrastructure from scratch, using the same tools and techniques you would in any
> famous FAANG company! Just remember us when you've added a letter to that acronym with your new
> billion dollar tech startup‽

## Further Reading & Examples &nbsp; ##

### ML in Spark ###

You can read the main ML library documentation [here](https://spark.apache.org/docs/latest/ml-guide.html)

- spark.ml package is now the primary API (data frame based api)
- spark.mllib package is now in maintenance mode (RDD-based API) available
[here](https://spark.apache.org/docs/latest/mllib-guide.html)

NOTE: SparkML (on DataFrames) supports ML pipelines and should therefore be your library of
choice for ML on Spark (e.g. in your assignment).

WARNING: While you can do ML with Spark in any of the languages we have covered, we do think it is
important to stress: **we recommend using Python for this!** There is a reason that python has
become the de-facto standard in ML and data science: it **excels** as a high-level glue language
for wrapping highly optimised libraries in other languages, moving data between them, and
orchestrating how they handle that data.

Further links:

- Python
    - [Connect Jupyter Notebook to a Spark Cluster](https://www.bmc.com/blogs/jupyter-notebooks-apache-spark/)
    - [Pyspark ml modules](https://spark.apache.org/docs/latest/api/python/reference/pyspark.ml.html)
- Scala/Java/Python
    - [Machine Learning with MLib](https://www.tutorialkart.com/apache-spark/apache-spark-mllib-scalable-machine-learning-library/)

You can start by running some of the examples available in `$SPARK_HOME/examples/src/main/python/ml/`
The corresponding code is also illustrated in the [MLlib manual](https://spark.apache.org/docs/latest/ml-guide.html)

### Statistical Correlation ###

The example is illustrated
[here](https://spark.apache.org/docs/latest/ml-statistics.html#correlation) and contained in
`correlation_example.py`

- start spark master and worker as seen in previous labs (if not running already)
- submit the task to your spark server
    ```sh
    spark-submit --master spark://spark-master:7077 examples/src/main/python/ml/correlation_example.py
    ```
- check in your output the spearman's and pearson's correlation matrix for the input vectors

### K-Means clustering ###

The example is illustrated [here](https://spark.apache.org/docs/latest/ml-clustering.html#k-means) and contained in `kmeans_example.py`

- start spark master and worker as seen in previous labs (if not running already)
- submit the task to your spark server
    ```sh
    spark-submit --master spark://spark-master:7077 examples/src/main/python/ml/kmeans_example.py
    ```
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

WARNING: You are likely to have a mix of data types (RDDs and DataFrames) in complex projects. When
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
        - Fit the model with training documents (`Estimator`)
        - Prepare test documents
        - Make prediction on test documents (`Transformer`)
    - Use spark-submit to run `spam-ham.py`

QUESTION: how would you modify the code to do sentiment analysis, using logistic regression?

###  Classification/Clustering examples ###

You can experiment with some of the provided examples of
[Classification](https://spark.apache.org/docs/latest/ml-classification-regression.html) and
[Clustering](https://spark.apache.org/docs/latest/ml-clustering.html) in the Spark Documentation.

### Recommender Systems example and resources ###

The Spark documentation recommendation is based on ALS matrix factorisation algorithms. Some
examples of how to build a RecSys based on Collaborative filtering with ALS in PySpark include:

- [Movie recommender](https://spark.apache.org/docs/latest/ml-collaborative-filtering.html)
- [Book recommender](https://medium.com/data-science/building-a-recommendation-engine-to-recommend-books-in-spark-f09334d47d67)

### Other ML libraries with Spark integrations ###

For this lab, Spark's dedicated ML libraries should be more than sufficient for achieving your
goals. However, it is always important to be aware of how the technology you're using fits in with
the broader ecosystem of the field in which you're working. Many non-Spark libraries also include
Spark integration, which (as discussed in [Lab 5](../lab5/index.md#what-is-spark)) is one of the
primary benefits of Spark's engine based model. Some of these offer more specialised or
cutting-edge ML capabilities, although can be slightly more challenging to write code using Spark
with them. Examples of some of the more common data science and ML libraries that can integrate
with Spark include:

- &nbsp; [SciKit Learn](https://scikit-learn.org/) ([spark-sklearn](https://github.com/databricks/spark-sklearn))
- 󱓞&nbsp; [XGBoost](https://xgboost.ai) ([tutorial](https://xgboost.readthedocs.io/en/stable/jvm/xgboost4j_spark_tutorial.html))
- 󱘎&nbsp; [LightGBM](https://lightgbm.readthedocs.io/en/stable/) ([SynapseML](https://microsoft.github.io/SynapseML/))
- &nbsp; [PyTorch](https://pytorch.org) ([documentation](https://spark.apache.org/docs/latest/api/python/reference/api/pyspark.ml.torch.distributor.TorchDistributor.html))
- &nbsp; [Tensorflow](https://tensorflow.org) ([tutorial](https://assets.docs.databricks.com/_extras/notebooks/source/deep-learning/spark-tensorflow-distributor.html))
- &nbsp; [Keras](https://keras.io) ([elephas](https://github.com/maxpumperla/elephas))
- &nbsp; [Horovod](https://horovod.ai/) ([documentation](https://horovod.readthedocs.io/en/stable/spark_include.html))

The ability to combine these tools with Spark demonstrates that it has become the de-facto standard
for distributed, HPC computations on big data in ML and data science.
