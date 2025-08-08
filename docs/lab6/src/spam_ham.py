from pyspark.ml import Pipeline, Transformer
from pyspark.ml.classification import LogisticRegression
from pyspark.ml.feature import HashingTF, Tokenizer
from pyspark.ml.evaluation import BinaryClassificationEvaluator
from pyspark.sql import SparkSession, DataFrame


def run_spam_classifier(
    train_df: DataFrame, test_df: DataFrame, num_features: int = 1000
) -> Transformer:
    """
    Builds, trains, and evaluates a spam classification pipeline.
    """
    # 1. Configure the ML Pipeline stages
    # Pipeline Stage 1: Tokenize the text messages into words
    tokenizer = Tokenizer(inputCol="text", outputCol="words")

    # Pipeline Stage 2: Hash the words into a numerical feature vector
    # numFeatures is a key parameter to tune! It determines how many embedding dimensions we will have.
    hashingTF = HashingTF(
        inputCol=tokenizer.getOutputCol(),
        outputCol="features",
        numFeatures=num_features,
    )

    # Pipeline Stage 3: The learning algorithm, a Logistic Regression classifier
    lr = LogisticRegression(maxIter=10, regParam=0.001, featuresCol="features", labelCol="label")

    # Chain the stages together into a Pipeline
    pipeline = Pipeline(stages=[tokenizer, hashingTF, lr])

    # 2. Train the model
    print("Fitting the pipeline to the training data...")
    model = pipeline.fit(train_df)

    # 3. Make predictions on the test data
    # The transform step applies all the pipeline stages to the new data
    predictions = model.transform(test_df)

    # 4. Let us print some intermediate results to understand how the pipeline works
    print(f"\n{' DataFrame Schema and Content after Transformation ':-^100}")
    predictions.printSchema()
    # Notice the new 'words' and 'features' columns added by the pipeline
    predictions.select("text", "words", "features", "label", "prediction").show(truncate=40)

    # 5. Evaluate the model's performance
    print(f"\n{' Evaluating Model Performance ':-^100}")
    evaluator = BinaryClassificationEvaluator(
        rawPredictionCol="rawPrediction", labelCol="label", metricName="areaUnderROC"
    )
    auc = evaluator.evaluate(predictions)
    print(f"Area Under ROC Curve (AUC) on Test Data = {auc:.4f}")
    print("(A value closer to 1.0 is better. 0.5 is random chance.)")

    # 6. Show final predictions in a scalable way
    print(f"\n{' Final Predictions ':-^100}")
    predictions.select("id", "text", "probability", "prediction").show(truncate=60)

    return model


if __name__ == "__main__":
    spark = SparkSession.builder.appName("PipelineExample").getOrCreate()

    # Prepare training documents
    training_data = spark.createDataFrame(
        [
            (0, "Meetup Spark user group Dublin", 0.0),
            (1, "Quick Loans availuble!", 1.0),
            (2, "New: The 20 pounds-per-day diet. Must try.", 1.0),
            (3, "hadoop mapreduce", 0.0),
            (4, "GET YOUR UUNIVERSITY DEGREE IN DATA ANALYSTICS. IN JUST 1 DAY", 1.0),
            (5, "URGENT call now for your prize", 1.0),
            (6, "Spark Summit 2025 registration is open", 0.0),
            (7, "Final project meeting tomorrow", 0.0),
            (8, "Click here for a free trial of our new software", 1.0),
            (9, "GET RICH WITH CRIPTO NOW!!!", 1.0),
            (10, "re: job application", 0.0),
            (11, "noreply", 0.0),
            (12, "Doctors hate this one simple trick!", 1.0),
            (13, "VIRUS ALERT!!", 1.0),
            (14, "Important! Read Carefully!!", 1.0),
            (15, "This game from your wishlist is now on sale!", 0.0),
            (16, "Updates to our terms of use", 0.0),
        ],
        ["id", "text", "label"],
    )

    # Split data into training and test sets (80% train, 20% test)
    # Choosing a fixed seed for operations allows us to make them deterministic and repeatable,
    # However, in a real training environment remember to randomly generate your seed! Best pratice
    # is to randomly generate your seed, but record it so you can repeat the experiment later.
    train, test = training_data.randomSplit([0.8, 0.2], seed=12345)
    print(f"Training data count: {train.count()}, Test data count: {test.count()}")

    # Run the entire workflow
    trained_model = run_spam_classifier(train, test, num_features=2156)

    spark.stop()
