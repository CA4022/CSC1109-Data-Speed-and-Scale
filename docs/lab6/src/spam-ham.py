from pyspark.ml import Pipeline
from pyspark.ml.classification import LogisticRegression
from pyspark.ml.feature import HashingTF, Tokenizer

from pyspark.sql import SparkSession

if __name__ == "__main__":
    spark = SparkSession.builder.appName("PipelineExample").getOrCreate()

# Prepare training documents from a list of (id, text, label) tuples, where label ham=0/spam=1
training = spark.createDataFrame(
    [
        (0, "Meetup Spark user group Dublin", 0.0),
        (1, "Quick Loans availuble!", 1.0),
        (2, "New: The 20 pounds-per-day diet. Must try.", 1.0),
        (3, "hadoop mapreduce", 0.0),
        (4, "GET YOUR UUNIVERSITY DEGREE IN DATA ANALYSTICS. IN JUST 1 DAY", 1.0),
    ],
    ["id", "text", "label"],
)

# Configure an ML pipeline, which consists of three stages: tokenizer, hashingTF, and lr.
tokenizer = Tokenizer(inputCol="text", outputCol="words")
hashingTF = HashingTF(inputCol=tokenizer.getOutputCol(), outputCol="features")
lr = LogisticRegression(maxIter=10, regParam=0.001)
pipeline = Pipeline(stages=[tokenizer, hashingTF, lr])

# Fit the pipeline to training documents.
model = pipeline.fit(training)

# Prepare test documents, which are unlabeled (id, text) tuples.
test = spark.createDataFrame(
    [
        (5, "I am not a spam, I promise!!!"),
        (6, "Spark can work on top of hadoop or standalone"),
        (7, "New release available for Spark on DataSets"),
    ],
    ["id", "text"],
)

# Make predictions on test documents and print columns of interest.
prediction = model.transform(test)
selected = prediction.select("id", "text", "probability", "prediction")
for row in selected.collect():
    rid, text, prob, prediction = row
    print("(%d, %s) --> prob=%s, prediction=%f" % (rid, text, str(prob), prediction))

spark.stop()
