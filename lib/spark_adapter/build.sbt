name := "visual_analytics"

assemblyJarName in assembly := s"${name.value}.jar"

version := "0.0.1"

scalaVersion := "2.11.12"
scalaVersion in ThisBuild := "2.11.12"

val sparkVersion = "2.2.1"
val hadoopVersion = "2.7.6"
val sparkDependencyScope = "provided"

libraryDependencies ++= Seq(
  "org.apache.spark" %%  "spark-core"    % sparkVersion  % sparkDependencyScope,
  "org.apache.spark" %%  "spark-sql"     % sparkVersion  % sparkDependencyScope,
  "org.apache.spark" %%  "spark-mllib"   % sparkVersion  % sparkDependencyScope,
  "joda-time"        %   "joda-time"     % "2.9.7",
  "org.json4s"       %%  "json4s-jackson" % "3.2.11"     % sparkDependencyScope,
  "org.scalatest"    %%    "scalatest"   % "3.0.5"       % "test" excludeAll (
    ExclusionRule(organization = "org.scala-lang"),
    ExclusionRule("org.slf4j", "slf4j-api")
  )
)

assemblyMergeStrategy in assembly := {
  case "log4j.properties" => MergeStrategy.first
  case x =>
    val oldStrategy = (assemblyMergeStrategy in assembly).value
    oldStrategy(x)
}

mainClass in assembly := Some("visual_analytics.Main")

test in assembly := {}

fork := true

javaOptions ++= Seq(
  "-dspark.master=local[*]",
  "-dspark.driver.memory=10g",
  "-dspark.default.parallelism=16",
  "-dlog4j.configuration=file:src/resources/log4j-defaults.properties",
  "-djava.util.logging.config.file=src/resources/parquet.logging.properties"
)

