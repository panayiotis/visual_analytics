package visual_analytics

import org.apache.spark.sql.functions.{col, substring, trunc}
import org.scalatest.{BeforeAndAfter, FunSpec,PrivateMethodTester}
import org.scalatest.Matchers._

import scala.runtime.ScalaRunTime.stringOf
import scala.io.Source

class SchemaSpec extends FunSpec with SharedSparkContext with BeforeAndAfter with PrivateMethodTester {

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
    val jsonPath = "../../spec/fixtures/files/schema.json"
    val json = Source.fromFile(jsonPath).getLines.mkString("\n")
    schema = Schema.fromJson(json)
  }


  describe("Schema") {

    describe("fromJson"){
      it("should create a Schema from a json with only the view key"){
        val json = """{"type":"","fields":{},"view":"view"}"""
        val schema = Schema.fromJson(json)
        schema.fields should have size 0
        assert(schema.view == "view")
      }
    }
    describe("fromView") {
      it("should create return Schema with 6 fields") {
        val schema = Schema.fromView("view")
        schema.fields should have size 6
      }
    }

    describe("validFieldsList") {
      it("should only contains fields from the supplied list") {
        assert(schema.validFieldsList(List("nuts_1", "date_year"))
          .lengthCompare(2) == 0)
      }
    }

    describe("toJson") {
      it("should convert to json string") {
        val expected =
          """{"type":"","fields":{"crime_type":{"name":"crime_type","level":"2","levels":["1","2"],"drill":[null,null]},"date":{"name":"date","level":"year","levels":["year","month"],"drill":["2016-01-01",null]},"nuts":{"name":"nuts","level":"1","levels":["0","1","2","3"],"drill":["UK",null,"UKI6",null]},"reported_by":{"name":"reported_by","level":null,"levels":[],"drill":[]}},"view":"view"}"""
        schema.toJson should equal(expected)
      }
    }

    describe("dataFrame") {
      it("should return a dataFrame with the expected columns") {
        val fields = schema.converge.dataFrame.schema.fields.map(_.name)
        val expectedFields = Set("crime_type", "reported_by", "date",
          "last_outcome_category", "falls_within", "nuts", "count")
        fields should contain theSameElementsAs expectedFields
      }

      it("should return a dataFrame with the expected filters applied") {
        assert(schema.dataFrame.select("nuts").distinct().count() == 1)
        assert(schema.dataFrame.select("date").distinct().count() == 1)
      }

      it("should return a dataFrame when no filters are set") {
        assert(Schema.fromView("view").dataFrame.count() > 100)
      }

    }
  }
}