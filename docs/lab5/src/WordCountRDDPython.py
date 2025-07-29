import re
import sys
from pyspark.sql import SparkSession

WORD_REGEX = re.compile(r"[^a-zA-Z']+")


def handle_line(line: str) -> list[str]:
    return WORD_REGEX.split(line.lower())


def word_count(spark: SparkSession, in_file: str, out_path: str):
    (
        spark.sparkContext.textFile(in_file)
        .flatMap(handle_line)
        .filter(bool)
        .map(lambda word: (word, 1))
        .reduceByKey(int.__add__)
        .saveAsTextFile(out_path)
    )


def main():
    if len(sys.argv) != 3:
        print("Usage: python WordCountRDDPython.py <in_file> <out_path>")
    else:
        in_file, out_path = sys.argv[1], sys.argv[2]
        spark = None
        try:
            spark = SparkSession.builder.appName("WordCountRDDPython").getOrCreate()
            word_count(spark, in_file, out_path)
        finally:
            if spark:
                spark.stop()


if __name__ == "__main__":
    main()
