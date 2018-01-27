tdeps = dirname(@__FILE__)
tika_jar = joinpath(tdeps, "tika-app-1.10.jar")
if !isfile(tika_jar)
    info("  Downloading tika-app-1.10.jar from Maven Central")
    download("http://search.maven.org/remotecontent?filepath=org/apache/tika/tika-app/1.10/tika-app-1.10.jar", tika_jar)
end

fop_jar = joinpath(tdeps, "fop-2,0", "fop-2.0.jar")
fop_gz = joinpath(tdeps, "fop-2.0-bin.tar.gz")

if !isfile(fop_gz)
    info("  Downloading fop-2.0 binary from Apache OSUOSL Mirror")
    download("http://apache.osuosl.org/xmlgraphics/fop/binaries/fop-2.0-bin.tar.gz", fop_gz)
end
if !isfile(fop_jar)
    if is_unix() unpack_cmd = `tar xzf $fop_gz --directory=$tdeps` end
    if is_windows()
        exe7z = joinpath(JULIA_HOME, "7z.exe")
        unpack_cmd = pipeline(`$exe7z x $fop_gz -y -so`,`$exe7z x -si -y -ttar -o$tdeps`)
    end
    run(unpack_cmd)
end
