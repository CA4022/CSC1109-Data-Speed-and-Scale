from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.ml.feature import BucketedRandomProjectionLSH, HashingTF, IDF, Normalizer, Tokenizer
from sklearn.datasets import fetch_openml


def fetch_and_prepare_data(spark):
    print("Fetching Dataset 43603 from OpenML...")
    dataset = fetch_openml(data_id=43603, as_frame=True, parser="auto")
    pdf = dataset.frame
    pdf = pdf.astype(str)
    pdf.fillna("", inplace=True)
    print(f"Data fetched. Shape: {pdf.shape}")
    print(f"Columns: {pdf.columns.tolist()}")
    df = spark.createDataFrame(pdf)
    return df


def build_recommender_pipeline(df):
    print("Preprocessing data...")
    df_clean = df.withColumn(
        "text_features",
        F.lower(F.concat_ws(" ", F.col("Genre"), F.col("Title"))),
    )
    tokenizer = Tokenizer(inputCol="text_features", outputCol="words")
    df_words = tokenizer.transform(df_clean)
    hashingTF = HashingTF(inputCol="words", outputCol="rawFeatures", numFeatures=2048)
    featurizedData = hashingTF.transform(df_words)
    idf = IDF(inputCol="rawFeatures", outputCol="features")
    idfModel = idf.fit(featurizedData)
    rescaledData = idfModel.transform(featurizedData)
    normalizer = Normalizer(inputCol="features", outputCol="normFeatures", p=2.0)
    normalizedData = normalizer.transform(rescaledData)
    return normalizedData


def train_lsh_model(df_features):
    print("Training LSH Model...")
    brp = BucketedRandomProjectionLSH(
        inputCol="normFeatures", outputCol="hashes", bucketLength=2.0, numHashTables=3
    )
    model = brp.fit(df_features)
    return model


def get_recommendations(model, df_features, query_title, num_recs=5):
    query_row = df_features.filter(F.lower(F.col("Title")).contains(query_title.lower())).first()
    if not query_row:
        print(f"Movie '{query_title}' not found in dataset.")
        return
    print(f"Finding recommendations for: {query_row['Title']} (Genre: {query_row['Genre']})")
    recs = model.approxNearestNeighbors(df_features, query_row["normFeatures"], num_recs + 1)
    recs = recs.filter(F.col("Title") != query_row["Title"])
    return recs.select("Title", "Genre", "Year", "distCol")


spark = SparkSession.builder.appName("Movie_Recommender").getOrCreate()

try:
    # Load
    df = fetch_and_prepare_data(spark)
    df.printSchema()

    # Build pipeline
    df_features = build_recommender_pipeline(df)

    # Train model
    lsh_model = train_lsh_model(df_features)

    # Predict
    search_query = "Godfather"
    num_recs = 5
    recommendations = get_recommendations(lsh_model, df_features, search_query, num_recs=num_recs)
    if recommendations:
        print(f"\n{'=' * 50}\nTOP {num_recs} RECOMMENDATIONS FOR '{search_query}':\n{'=' * 50}")
        recommendations.show(truncate=False)

except Exception as e:
    raise e
finally:
    spark.stop()
