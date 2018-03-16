name := "starterkit"
version := "1.0"
scalaVersion := "2.11.8"

initialCommands in consoleQuick := "import better.files.File"

libraryDependencies ++=
  Seq("com.github.pathikrit" %% "better-files"  % "3.4.0",
      "org.json4s"           %% "json4s-native" % "3.2.11",
      "org.scalatest"        %% "scalatest"     % "3.0.5" % "test",
      "com.typesafe"         %  "config"        % "1.3.2",
      "joda-time"            %  "joda-time"     % "2.9.9")
