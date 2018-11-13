import org.apache.spark.sql.SparkSession

object Model {

  def main(args: Array[String]): Unit = {

    build()

  }

  def build(): Unit = {

    val spark = SparkSession.builder()
      .appName("toxicity")
      .master("local[*]")
      .getOrCreate()

    val data = spark.read
      .format("csv")
      .option("header", "true")
      .load("src/main/resources/train.csv")

    println(data)

    spark.close()

  }

}
