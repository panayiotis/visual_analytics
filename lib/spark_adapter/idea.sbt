/**
  * This sbt file is intended for IntelliJ IDEA.
  * build.sbt lists the hadoop/spark library dependencies as *provided* so
  * idea.sbt is used by IntelliJ to resolve the libraries in compile time.
  *
  */

scalaVersion := "2.11.12"

val sparkVersion = "2.2.1"
val hadoopVersion = "2.7.6"
val sparkDependencyScope = "compile"

lazy val idea = project.in(file(".idea/idea-module"))
  .dependsOn(RootProject(file(".")))
  .settings(
    libraryDependencies ++= Seq(
      "org.apache.spark" %%  "spark-core"     % sparkVersion % sparkDependencyScope,
      "org.apache.spark" %%  "spark-sql"      % sparkVersion % sparkDependencyScope,
      "org.apache.spark" %%  "spark-mllib"    % sparkVersion % sparkDependencyScope,
      "org.json4s"       %%  "json4s-jackson" % "3.2.11"     % sparkDependencyScope
    )
  )
  .disablePlugins(sbtassembly.AssemblyPlugin)
