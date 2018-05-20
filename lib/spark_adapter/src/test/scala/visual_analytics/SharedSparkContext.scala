package visual_analytics

import org.apache.spark.sql.SparkSession
import org.apache.spark.{SparkConf, SparkContext}
import org.scalatest.{BeforeAndAfterAll, Suite}

/** Shares a local `SparkContext` between all tests in a suite and closes it at the end */
trait SharedSparkContext extends BeforeAndAfterAll { self: Suite =>

  @transient private var _spark: SparkSession = _

  def spark: SparkSession = _spark

  override def beforeAll() {
    super.beforeAll()
    println("initialize suite: create sparksession")
    _spark = SparkSession.builder().appName("Test").getOrCreate()
  }

  override def afterAll() {
    try {
      if (_spark != null) {
        _spark.stop()
      }
      // To avoid RPC rebinding to the same port, since it doesn't unbind immediately on shutdown
      System.clearProperty("spark.driver.port")
      _spark = null
    } finally {
      super.afterAll()
    }
  }
}