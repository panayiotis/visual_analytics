package visual_analytics

import org.apache.spark.sql.{DataFrame, SparkSession}
import org.json4s
import org.json4s._
import org.json4s.jackson.JsonMethods._
import org.json4s.JsonDSL._

import scala.collection.mutable
import scala.runtime.ScalaRunTime.stringOf

import java.nio.file.{Paths, Files}
import java.util.zip.GZIPOutputStream
import java.io._

/**
  * Created on 06/03/17.
  */
object Run {

  def apply(jsonOrView: String = "view",
            path: String = "/var/data/storage",
            mock: Boolean = false)
  : Unit
  = {

    val trimmedPath = path.replaceAll("^/+$", "")

    if (mock) {
      val filename = s"$trimmedPath/view63c55.json"
      val key = "view63c55"
      val response =
        s"""{
           |  "key": "$key",
           |  "byte_size": 123,
           |  "mock": true
           |}""".stripMargin
      println(response)
      return
    }

    val schema = if (jsonOrView.matches("""^\s*\{.+""")) {
      val json = jsonOrView
      Schema.fromJson(json).converge // load schema from json and converge
    } else {
      val view = jsonOrView
      Schema.fromView(view) // no need to converge if schema is loaded from view
    }

    val filename = s"$trimmedPath/${schema.sha256Hash}.json"

    if (Files.exists(Paths.get(filename))) {
      val response =
        s"""{
           |  "key": "${schema.sha256Hash}",
           |  "cached": true
           |}""".stripMargin
      println(response)
    } else {

      //System.err.println(schema.toJson)
      val df = schema.dataFrame
      val dataJsonString = df.coalesce(1).toJSON.collect().mkString(",\n")
      val byteSize = dataJsonString.length()
      val jsonContent =
        s"""{
        "schema": ${schema.toJson},
        "data": [
        $dataJsonString
        ]
        }""".stripMargin

      // create path
      new File(trimmedPath).mkdirs()

      writeJson(filename, jsonContent)
      val response =
        s"""{
           |  "key":"${schema.sha256Hash}",
           |  "byte_size": ${jsonContent.length}
           |}""".stripMargin
      println(response)
    }
  }

  private def writeJson(filename: String, content: String): Unit = {
    val bw = new BufferedWriter(new FileWriter(new File(s"$filename")))
    bw.write(content)
    bw.close()

    val gzipOutput = new FileOutputStream(s"$filename.gz")
    val gzipWriter = new PrintWriter(new GZIPOutputStream(gzipOutput))
    gzipWriter.write(content)
    gzipWriter.close()
    gzipOutput.close()
  }

  def views(mock: Boolean = false): Unit = {
    val json = if (mock) {
      """{"views":[{"name":"view","tableType":"TEMPORARY","isTemporary":true}]}"""
    } else {
      spark.catalog.listTables()
        .coalesce(1).toJSON.collect()
        .mkString("{\"views\":[", ",\n", "]}")
    }
    println(json)
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
}
