package visual_analytics

import org.apache.spark.sql.functions.{col, substring, trunc}
import org.scalatest.Matchers._
import org.scalatest.{BeforeAndAfter, FunSpec}

import scala.io.Source

class FieldSpec extends FunSpec with SharedSparkContext with BeforeAndAfter {

  var schema: Schema = _

  describe("Field") {

    describe("nameWithLevel") {

      it("should return the correct name for nuts fields") {
        val field = Field("nuts", "1", List("0", "1", "2", "3"), List("UK", "null", "UKI6", "null"))
        assert(field.nameWithLevel === "nuts_1")
      }

      it("should return the correct name for date fields") {
        val field = Field("date", "year", List("day", "month", "year"), List("null", "null", "null"))
        assert(field.nameWithLevel === "date_year")
      }

      it("should return the correct name for other fields") {
        val field = Field("other", "0", List("0", "1", "2", "3"), List("null", "null", "null", "null"))
        assert(field.nameWithLevel === "other_level_0")
      }
    }

    describe("filterExpression") {
      it("should return the correct filterExpression") {
        val field = Field("nuts", "1",
          List("0", "1", "2", "3"),
          List("UK", "null", "UKI6", null))
        assert(field.filterExpression ===
          """nuts_0 = "UK" and nuts_2 = "UKI6"""")
      }

      it("should return empty string when no filters are applied") {
        val field = Field("nuts", "1",
          List("0", "1", "2", "3"),
          List("null", "null", null, null))
        assert(field.filterExpression.isEmpty)
      }
    }

    describe("toJson") {
      it("should return the correct json string") {
        val field = Field("nuts", "1", List("0", "1", "2", "3"), List("UK", "null", "UKI6", "null"))
        val expected = """{"name":"nuts","level":"1","levels":["0","1","2","3"],"drill":["UK","null","UKI6","null"]}"""
        assert(field.toJson === expected)
      }
    }

    describe("reconcile") {
      it("should update level when level exists") {
        val a = Field("field_name", "level_1", List[String]("level_1", "level_2"), List[String](null, null))
        val b = Field("field_name", "level_2", List[String]("level_1", "level_2"), List[String](null, null))
        val c = a.converge(b)
        assert(c.level === "level_2")
      }

      it("should not update level if level has disappeared") {
        val a = Field("field_name", "level_1", List[String]("level_1"), List[String](null))
        val b = Field("field_name", "level_2", List[String]("level_1", "level_2", "level_2"), List[String](null, null, null))
        val c = a.converge(b)
        assert(c.level === "level_1")
      }

      it("should reconcile the drill array") {
        val a = Field("field_name", "level_1", List[String]("level_1", "level_2", "level_3", "level_4", "level_5", "level_6"), List[String](null, null, null, null, null, null))
        val b = Field("field_name", "level_2", List[String]("level_1", "level_3", "level_4", "level_7", "level_8"), List[String]("drill_1", null, "drill_4", "drill_7", null))
        val c = a.converge(b)
        c.drill should contain theSameElementsAs List("drill_1", null, null, "drill_4", null, null)
      }
    }
  }
}