import sys
from pyspark.sql import SparkSession
from pyspark.sql.functions import col, lower, split, explode


def word_count(spark: SparkSession, in_file: str, out_path: str):
    spark.read.text(in_file) \
        .select(
            explode(
                split(lower(col("value")), r"[^a-zA-Z']+")
            ).alias("word")
        ) \
        .where(col("word") != "") \
        .groupBy("word") \
        .count() \
        .write.mode("overwrite").option("delimiter", ": ").csv(out_path)


def main():
    if len(sys.argv) != 3:
        print("Usage: python WordCountDFPython.py <in_file> <out_path>")
    else:
        in_file, out_path = sys.argv[1], sys.argv[2]
        spark = None
        try:
            spark = SparkSession.builder.appName("WordCountDFPython").getOrCreate()
            word_count(spark, in_file, out_path)
        finally:
            if spark:
                spark.stop()


if __name__ == "__main__":
    main()
