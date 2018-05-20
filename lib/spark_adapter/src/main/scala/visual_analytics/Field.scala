package visual_analytics

import org.apache.spark.sql.{DataFrame, SparkSession}
import org.json4s
import org.json4s.JsonDSL._
import org.json4s._
import org.json4s.jackson.JsonMethods._

import scala.collection.mutable
import scala.runtime.ScalaRunTime.stringOf

/**
  * Field of Schema
  * Created on 06/03/17.
  */
object Field {
  def apply(name: String, level: String, levels: List[String],
            drill: List[String]): Field = {
    new Field(name, level, levels, drill)
  }
}

class Field(val name: String, val level: String, val levels: List[String],
            val drill: List[String]) {

  def selectExpr: String = s"$nameWithLevel as $name"

  def nameWithLevel: String = nameWithLevel(level)

  def groupCol: String = nameWithLevel

  /**
    * Constructs the filter expression string by combining the levels and drill
    * arrays. An example is: nuts_0 = UK and nuts_2 = UKI6
    */
  def filterExpression: String = {
    drill.zip(levels)
      .filter(_._1 != "null")
      .filter(_._1 != null)
      .map({ case (d, l) => s"""${nameWithLevel(l)} = "$d"""" })
      .mkString(" and ")
  }

  def nameWithLevel(level: String): String = {
    if (levels.nonEmpty) {
      if (List("nuts", "date") contains name) {
        s"${name}_$level"
      }
      else {
        s"${name}_level_$level"
      }
    } else {
      name
    }
  }

  /**
    * Converge this field with another field and return a new field.
    * This action is not commutative.
    * The returned field has the level of the other field, the levels array
    * of this field and the drill array of the other field if the levels of the
    * other field are also present on this field.
    *
    * @param otherField the other field that is going to be converged
    * @return the resulted converged field
    */
  def converge(otherField: Field): Field = {
    if (otherField == null) {
      return this
    }

    // converge level
    val newLevel = if (levels.contains(otherField.level)) {
      otherField.level
    } else {
      level
    }

    // converge drill array
    val drillMap = levels.zip(drill).toMap

    val otherDrillMap = otherField.levels.zip(otherField.drill).toMap

    val convergeDrillMap = drillMap.map { case (key, value) =>
      if (otherDrillMap.contains(key)) {
        (key, otherDrillMap(key))
      } else {
        (key, value)
      }
    }

    val newDrill = levels.map(l => convergeDrillMap(l))

    // levels array remains the same
    Field(name = name, level = newLevel, levels = levels, drill = newDrill)
  }

  def toJson: String = {
    compact(toJsonAST)
  }

  def toJsonAST: json4s.JObject = {
    ("name" -> name) ~
      ("level" -> level) ~
      ("levels" -> levels) ~
      ("drill" -> drill)
  }
}


