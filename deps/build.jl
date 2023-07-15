using p7zip_jll

tdeps = dirname(@__FILE__)
tika_jar = joinpath(tdeps, "tika-app-1.23.jar")
if !isfile(tika_jar)
    @info "  Downloading tika-app-1.23.jar from Apache Archive"
    download("https://archive.apache.org/dist/tika/tika-app-1.23.jar", tika_jar)
end

fop_dir = joinpath(tdeps, "fop-2.3", "fop")
fop_jar = joinpath(fop_dir, "build", "fop-2.3.jar")
fop_lib = joinpath(fop_dir, "lib" )
fop_gz = joinpath(tdeps, "fop-2.3-bin.tar.gz")

if !isfile(fop_gz)
    @info "  Downloading fop-2.3 binary from Apache OSUOSL Mirror"
    download("https://archive.apache.org/dist/xmlgraphics/fop/binaries/fop-2.3-bin.tar.gz", fop_gz)
end
if !isfile(fop_jar)
    if Sys.isunix() unpack_cmd = `tar xzf $fop_gz --directory=$tdeps` end
    if Sys.iswindows()
        const exe7z = p7zip_jll.p7zip()
        unpack_cmd = pipeline(`$exe7z x $fop_gz -y -so`,`$exe7z x -si -y -ttar -o$tdeps`)
    end
    run(unpack_cmd)
end
