package visual_analytics

import org.apache.spark.sql.{DataFrame, SparkSession}
import org.json4s
import org.json4s.JsonDSL._
import org.json4s._
import org.json4s.jackson.JsonMethods._

import scala.collection.mutable
import scala.runtime.ScalaRunTime.stringOf

import java.math.BigInteger
import java.security.MessageDigest

/**
  * Created on 06/03/17.
  */
object Schema {

  /**
    * Create a Schema from a JSON string.
    *
    * @param json a JSON string
    * @return a Schema
    */
  def fromJson(json: String): Schema = {
    implicit val formats: DefaultFormats.type = DefaultFormats
    parse(json).extract[Schema]
  }

  /**
    * Create a Schema from a Spark view.
    * If the view is does not exists, Spark throws an exception.
    *
    * @param view a string with the name of the spark view
    * @return a Schema
    */
  def fromView(view: String): Schema = {
    val df = spark.table(view)

    val columnNames = df.schema.fields.map(_.name).toList

    val a = columnNames.foldLeft(
      mutable.Map[String, mutable.MutableList[String]]()
    ) {
      (acc: mutable.Map[String, mutable.MutableList[String]],
       columnName: String) => {
        val (name, level) = parseColumnName(columnName)
        //println(name, level.getOrElse("-"))
        if (acc.contains(name)) {
          acc(name) += level.get
          acc
        } else {
          if (level.isEmpty) {
            acc.put(name, mutable.MutableList[String]())
            acc
          } else {
            acc.put(name, mutable.MutableList(level.get))
            acc
          }
        }
      }
    }
      .mapValues(v => v.toList)
      .toMap

    val b = a.map { case (key, list) =>
      // The levels array should be sorted from generic to specific.
      // This is a quick hack to achieve this by sorting the array
      // lexicographically and spesificaly sort the `date` array in reverse
      // order (year > month > day).
      val sortedList = sortLevelsList(list)
      if (list.isEmpty) {
        key -> Field(name = key, level = null, levels = list,
          drill = list)
      } else {
        key -> Field(name = key,
          level = sortedList.head,
          levels = sortedList,
          drill = list.map(_ => null))
      }
    }
    Schema(`type` = df.schema.typeName, fields = b, view = view)
  }

  /**
    * Returns the active SparkSession. If it is not found, it throws an
    * exception.
    *
    * @return the active SparkSession
    */
  private def spark: SparkSession = {
    if (SparkSession.getActiveSession.isEmpty) {
      throw new Exception(
        "VisualAnalytics: an active SparkSession was not found"
      )
    }
    SparkSession.getActiveSession.get
  }

  def apply(`type`: String, fields: Map[String, Field],
            view: String): Schema = {
    new Schema(`type`, fields, view)
  }

  /**
    * Extracts a name and a level from a Spark DataFrame column name.
    *
    * @param columnName the name of the Spark DataFrame column
    * @return a tuple of the name and level
    */
  private def parseColumnName(columnName: String): (String, Option[String]) = {
    val nutsRegex = """^nuts_(\w+)$""".r
    val dateRegex = """^date_(\w+)$""".r
    val hierarchicalRegex = """^(\w+)_level_(\w+)$""".r

    columnName match {
      case nutsRegex(level) => Tuple2("nuts", Some(level))
      case dateRegex(level) => Tuple2("date", Some(level))
      case hierarchicalRegex(name, level) => Tuple2(name, Some(level))
      case _ => Tuple2(columnName, None)
    }
  }

  private def sortLevelsList(levels: List[String]): List[String] = {
    if (levels.contains("year")) {
      levels.sorted.reverse
    } else {
      levels.sorted
    }
  }
}

class Schema(val `type`: String,
             val fields: Map[String, Field],
             val view: String) {

  def validFieldsList(names: List[String]): List[Field] = {
    fieldsList.filter(field => names.contains(field.nameWithLevel))
  }

  /**
    * It creates a Schema from the Spark view and converges each field
    * from the fresh Schema with each field from this Schema
    *
    * @return a converged Schema
    */
  def converge: Schema = {
    val secondary = this
    val primary = Schema.fromView(secondary.view)

    val `type` = primary.`type`
    val view = primary.view
    val fields = primary.fields.mapValues {
      field => {
        field.converge(
          secondary.fields.getOrElse(key = field.name, default = null)
        )
      }
    }
    Schema(`type` = `type`, fields = fields, view = view)
  }

  /**
    * Return the Spark DataFrame that coresponds to the specified Schema.
    * Uses the level, levels and drill information to apply filters and
    * aggregations.
    */
  def dataFrame: DataFrame = {
    val df = Schema.spark.table(view)
    val fields = fieldsList.filter(field => {
      df.schema.fieldNames.contains(field.nameWithLevel)
    })

    val fieldNames = fields.map(_.nameWithLevel)

    val groupColumns = fieldNames.map(df.col)

    val filterExpression = fields
      .map(_.filterExpression)
      .filter(_.nonEmpty)
      .mkString(" and ")

    val selectColumns: List[String] = fields.map(_.selectExpr) ++ List("count")

    //System.err.println(s"select col: ${stringOf(selectColumns)}")
    //System.err.println(s"group col:  ${stringOf(groupColumns)}")
    //System.err.println(s"filter exp: ${stringOf(filterExpression)}")

    val df2 = if (filterExpression.nonEmpty) {
      df.filter(filterExpression)
    } else {
      df
    }

    df2.groupBy(groupColumns: _*)
      .count()
      .selectExpr(selectColumns: _*)
  }

  def fieldsList: List[Field] = fields.values.toList

  def toJson: String = {
    compact(toJsonAST)
  }

  def toJsonAST: json4s.JObject = {
    ("type" -> `type`) ~
      ("fields" -> fields.values.toSeq.sortBy(_.name).map(f => (f.name, f
        .toJsonAST)).toMap) ~
      ("view" -> view)
  }

  def sha256Hash: String = {
    val bytes = toJsonForHash.getBytes("UTF-8")
    val digest = MessageDigest.getInstance("SHA-256").digest(bytes)
    val hexDigest = String.format("%064x", new BigInteger(1, digest))
    view.concat(hexDigest.slice(from = 0, until = 5))
  }

  private def toJsonForHash: String = {
    compact(fields.values.toSeq.sortBy(f => f.name).map(_.toJsonAST))
  }
}



