tika_jar = joinpath(Pkg.dir(), "Taro", "deps", "tika-app-1.4.jar")
if !isfile(tika_jar)
	info("    Downloading tika-app-1.4.jar from Maven Central")
	download("http://search.maven.org/remotecontent?filepath=org/apache/tika/tika-app/1.4/tika-app-1.4.jar", tika_jar)
end
