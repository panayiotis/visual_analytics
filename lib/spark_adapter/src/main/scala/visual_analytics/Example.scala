package visual_analytics

import org.apache.spark.sql.functions._
import org.apache.spark.sql.{DataFrame, SaveMode, SparkSession}

import scala.io.Source
import org.json4s._
import org.json4s.jackson.JsonMethods._
import scala.runtime.ScalaRunTime.stringOf
import visual_analytics.Run._

/**
  * Created on 06/03/17.
  */
object Example {

  def main(args: Array[String]) {
    println("Example")

    val spark = SparkSession
      .builder()
      .getOrCreate()

    println("Create view")

    spark.read.parquet("/var/data/uk_crime/asb_nuts.parquet").
      drop("crime_id").drop("longitude").drop("latitude").drop("location")
      .drop("lsoa_code").drop("lsoa_name").drop("context").na.fill(Map(
      "last_outcome_category" -> "Unknown"
    )).
      cache.
      withColumn("nuts_2", substring(col("nuts_3"), 0, 4)).
      withColumn("nuts_1", substring(col("nuts_3"), 0, 3)).
      withColumn("nuts_0", substring(col("nuts_3"), 0, 2)).
      withColumn("date_year", trunc(col("date_month"), "year")).
      createOrReplaceTempView("view")

    spark.table("view").show(3)

    println("Create json from view")
    print("key: ")
    println(Schema.fromView("view").sha256Hash)
    Run("view")
    Run.views()
  }
}
