import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;

import scala.Tuple2;

import java.util.Arrays;
import java.util.regex.Pattern;

public final class WordCountJava {
    private static final Pattern PATTERN = Pattern.compile("[^a-zA-Z']+");

    public static void main(String[] args) throws Exception {
        if (args.length < 2) {
            System.err.println("Usage: WordCount <input-file> <output-dir>");
            System.exit(1);
        }

        String inputPath = args[0];
        String outputPath = args[1];

        SparkConf sparkConf = new SparkConf().setAppName("WordCountJava");

        try (JavaSparkContext sc = new JavaSparkContext(sparkConf)) {
            JavaRDD<String> lines = sc.textFile(inputPath);
            JavaRDD<String> words = lines.flatMap(s -> Arrays.asList(PATTERN.split(s.toLowerCase())).iterator());
            JavaRDD<String> nonEmptyWords = words.filter(word -> !word.trim().isEmpty());
            JavaPairRDD<String, Integer> ones = nonEmptyWords.mapToPair(word -> new Tuple2<>(word, 1));
            JavaPairRDD<String, Integer> counts = ones.reduceByKey((i1, i2) -> i1 + i2);
            counts.saveAsTextFile(outputPath);
        }
    }
}
