import fsspec
from pyspark.sql import DataFrame, SparkSession
from pyspark.sql import functions as F
from pyspark.ml import Pipeline, PipelineModel, Transformer
from pyspark.ml.feature import (
    BucketedRandomProjectionLSH,
    BucketedRandomProjectionLSHModel,
    HashingTF,
    IDF,
    Normalizer,
    RegexTokenizer,
    StopWordsRemover,
)
import requests


def fetch_and_prepare_data(spark: SparkSession) -> DataFrame:
    dataset_id = 43603
    output_path = "hdfs://namenode/data/imdb.pq"

    api_url = f"https://www.openml.org/api/v1/json/data/{dataset_id}"
    print(f"Fetching metadata from: {api_url}")
    api_response = requests.get(api_url, timeout=30)
    api_response.raise_for_status()

    print("Parsing API response for Parquet URL...")
    metadata = api_response.json()
    parquet_url = metadata["data_set_description"]["parquet_url"]
    assert parquet_url

    print(f"Found Parquet URL: {parquet_url}")

    fs = fsspec.filesystem("hdfs", host="namenode")

    print(f"Streaming data to HDFS path: {output_path}")
    # Note: Ideally we would do this download on the worker's side, but for simplicity
    #     let's keep it on the driver as shown below
    with requests.get(parquet_url, stream=True) as r, fs.open(output_path, "wb") as f:
        r.raise_for_status()
        written = sum(f.write(chunk) for chunk in r.iter_content(chunk_size=8192))
        print(f"Successfully streamed {written} bytes to HDFS.")

    df = spark.read.parquet(output_path)
    print("Data loaded as spark dataframe with schema:")
    df.printSchema()
    return df


class ConcatenateTextFeatures(Transformer):
    def __init__(self, inputCols: list[str] | None = None):
        super().__init__()
        self.inputCols = inputCols if inputCols is not None else []

    def _transform(self, dataset: DataFrame) -> DataFrame:
        return dataset.withColumn(
            "text_features",
            F.lower(
                F.concat_ws(" ", *[F.col(col) for col in self.inputCols]),
            ),
        )


def build_pipeline() -> Pipeline:
    return Pipeline(
        stages=[
            ConcatenateTextFeatures(["Title", "Genre", "Director", "Actors", "Description"]),
            RegexTokenizer(
                inputCol="text_features",
                outputCol="words",
                pattern="[^a-zA-Z']+",
                toLowercase=True,
                minTokenLength=1,
            ),
            StopWordsRemover(inputCol="words", outputCol="importantWords"),
            HashingTF(inputCol="importantWords", outputCol="rawFeatures", numFeatures=65536),
            IDF(inputCol="rawFeatures", outputCol="features"),
            Normalizer(inputCol="features", outputCol="normFeatures", p=2.0),
            BucketedRandomProjectionLSH(
                inputCol="normFeatures", outputCol="hashes", bucketLength=2.0, numHashTables=3
            ),
        ],
    )


def get_closest_string(df: DataFrame, column_name: str, search_query: str) -> str:
    # This is an inefficient way to fuzzy search for large datasets,
    #    but for this example should be acceptable
    distance_df = df.withColumn(
        "distance",
        F.levenshtein(F.col(column_name), F.lit(search_query)),
    )

    min_distance = distance_df.agg(F.min("distance").alias("min_distance")).collect()[0][
        "min_distance"
    ]

    closest_match = distance_df.filter(F.col("distance") == min_distance).first()

    if closest_match is None:
        raise ValueError(
            f"No matching string found for '{search_query}' in column '{column_name}'."
        )

    return closest_match[column_name]


def get_recommendations(
    model: PipelineModel,
    feature_df: DataFrame,
    search_query: str,
    num_recs: int = 5,
) -> tuple[str, DataFrame]:
    closest_film = get_closest_string(feature_df, "Title", search_query)
    print(f"Closest match to '{search_query}' found in dataset: {closest_film}")

    query_feature_df = feature_df.where(F.col("Title") == closest_film)
    assert query_feature_df is not None, f"Movie '{search_query}' not found in the dataset."

    lsh_model = next(
        (stage for stage in model.stages if isinstance(stage, BucketedRandomProjectionLSHModel)),
        None,
    )
    if not lsh_model:
        raise ValueError("Pipeline must contain a BucketedRandomProjectionLSHModel")

    query_feature_vector = query_feature_df.head(1)[0]["normFeatures"]
    similarity_df = lsh_model.approxNearestNeighbors(feature_df, query_feature_vector, num_recs + 1)
    recommendations_df = similarity_df.filter(F.col("Title") != closest_film)
    return closest_film, recommendations_df.select(
        "Title", "distCol", "Genre", "Director", "Actors", "Description"
    )


spark = SparkSession.builder.appName("Movie_Recommender").getOrCreate()

try:
    # Load
    df = fetch_and_prepare_data(spark)
    df.printSchema()

    # Build pipeline
    pipeline = build_pipeline()

    # Train model and get feature vectors
    model = pipeline.fit(df)
    feature_df = model.transform(df)

    # Predict
    search_query = "Alien"
    num_recs = 5
    search_match, recommendations = get_recommendations(model, feature_df, search_query, num_recs)
    if recommendations:
        print(f"\n{'=' * 50}\nTOP {num_recs} RECOMMENDATIONS FOR '{search_match}':\n{'=' * 50}")
        recommendations.show(truncate=False)

except Exception as e:
    raise e
finally:
    spark.stop()
