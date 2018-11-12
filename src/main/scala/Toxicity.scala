import org.apache.spark.SparkConf
import org.apache.spark.streaming.twitter.TwitterUtils
import org.apache.spark.streaming.{Seconds, StreamingContext}

object Toxicity {

  def main(args: Array[String]): Unit = {

    val conf = new SparkConf()
    conf.setMaster("local[*]")
    conf.setAppName("toxicity")

    val scc = new StreamingContext(conf, Seconds(5))


    val tweets = TwitterUtils.createStream(scc, None)


    tweets.map(_.getText).print()

    scc.start()

    scc.awaitTermination()

  }

}
