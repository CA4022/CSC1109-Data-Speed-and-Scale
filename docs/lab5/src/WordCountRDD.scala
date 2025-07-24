import org.apache.spark.SparkContext
import org.apache.spark.SparkConf

object WordCountRDD {
  def main(args: Array[String]): Unit = {
    if (args.length != 2) {
      System.err.println("Usage: WordCount <input-file> <output-file>")
      System.exit(1)
    }

    val inputPath = args(0)
    val outputPath = args(1)

    val sparkConf = new SparkConf().setAppName("WordCountRDD")
    val sc = new SparkContext(sparkConf)

    try {
      sc.textFile(inputPath)
        .flatMap(_.toLowerCase.split("[^a-zA-Z']+"))
        .filter(_.nonEmpty)
        .map((_, 1))
        .reduceByKey(_ + _)
        .saveAsTextFile(outputPath)
    } catch {
      case e: Exception =>
        println(s"An error occurred: ${e.getMessage}")
        e.printStackTrace()
    } finally {
      sc.stop()
    }
  }
}
