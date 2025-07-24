import org.apache.spark.sql.SparkSession

object WordCountDS {
  def main(args: Array[String]): Unit = {
    if (args.length != 2) {
      System.err.println("Usage: WordCount <input-file> <output-file>")
      System.exit(1)
    }

    val inputPath = args(0)
    val outputPath = args(1)

    val spark = SparkSession.builder().appName("WordCountDS").getOrCreate()
    import spark.implicits._

    try {
      spark.read.textFile("data/Word_count.txt")
        .flatMap(_.toLowerCase.split("[^a-zA-Z']+"))
        .filter(_.nonEmpty)
        .groupBy("value").count()
        .write.csv(outputPath)
    } catch {
      case e: Exception =>
        println(s"An error occurred: ${e.getMessage}")
        e.printStackTrace()
    } finally {
      spark.stop()
    }
  }
}
