package visual_analytics

import org.apache.spark.sql.functions.{col, substring, trunc}
import org.scalatest.{BeforeAndAfter, FunSpec}
import org.scalatest.Matchers._
import visual_analytics.Run._

import scala.io.Source

class RunSpec extends FunSpec with SharedSparkContext with BeforeAndAfter {

  var schema: Schema = _

  override def beforeAll(): Unit = {
    super.beforeAll()
    spark.read.parquet("/var/data/uk_crime/asb_nuts_sample_0001.parquet").
      drop("crime_id").drop("longitude").drop("latitude").drop("location")
      .drop("lsoa_code").drop("lsoa_name").drop("context").
      withColumn("nuts_2", substring(col("nuts_3"), 0, 4)).
      withColumn("nuts_1", substring(col("nuts_3"), 0, 3)).
      withColumn("nuts_0", substring(col("nuts_3"), 0, 2)).
      withColumn("date_year", trunc(col("date_month"), "year"))
      .createTempView("view")
  }

  before {
    val jsonPath =
      "/home/panos/Work/visual_analytics/spec/fixtures/files/schema.json"

    val json = Source.fromFile(jsonPath).getLines.mkString("\n")
    schema = Schema.fromJson(json)
  }
    describe("apply") {
      it("should...") {
        Run("view")
      }
    }
}
