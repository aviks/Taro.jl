tdeps = dirname(@__FILE__)
tika_jar = joinpath(tdeps, "tika-app-1.19.jar")
if !isfile(tika_jar)
    @info "  Downloading tika-app-1.17.jar from Maven Central"
    download("https://apache.osuosl.org/tika/tika-app-1.19.1.jar", tika_jar)
end

fop_dir = joinpath(tdeps, "fop-2.3", "fop")
fop_jar = joinpath(fop_dir, "build", "fop-2.3.jar")
fop_lib = joinpath(fop_dir, "lib" )
fop_gz = joinpath(tdeps, "fop-2.3-bin.tar.gz")

if !isfile(fop_gz)
    @info "  Downloading fop-2.3 binary from Apache OSUOSL Mirror"
    download("https://apache.osuosl.org/xmlgraphics/fop/binaries/fop-2.3-bin.tar.gz", fop_gz)
end
if !isfile(fop_jar)
    if Sys.isunix() unpack_cmd = `tar xzf $fop_gz --directory=$tdeps` end
    if Sys.iswindows()
        exe7z = joinpath(JULIA_HOME, "7z.exe")
        unpack_cmd = pipeline(`$exe7z x $fop_gz -y -so`,`$exe7z x -si -y -ttar -o$tdeps`)
    end
    run(unpack_cmd)
end
