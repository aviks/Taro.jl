tdeps = dirname(@__FILE__)
tika_jar = joinpath(tdeps, "tika-app-1.23.jar")
if !isfile(tika_jar)
    @info "  Downloading tika-app-1.23.jar from Apache Archive"
    download("https://archive.apache.org/dist/tika/tika-app-1.23.jar", tika_jar)
end

fop_dir = joinpath(tdeps, "fop-2.6", "fop")
fop_jar = joinpath(fop_dir, "build", "fop-2.6.jar")
fop_lib = joinpath(fop_dir, "lib" )
fop_gz = joinpath(tdeps, "fop-2.6-bin.tar.gz")

if !isfile(fop_gz)
    @info "  Downloading fop-2.6 binary from Apache OSUOSL Mirror"
    download("https://apache.osuosl.org/xmlgraphics/fop/binaries/fop-2.6-bin.tar.gz", fop_gz)
end
if !isfile(fop_jar)
    if Sys.isunix() unpack_cmd = `tar xzf $fop_gz --directory=$tdeps` end
    if Sys.iswindows()
        if isdefined(Base, :LIBEXECDIR)
          const exe7z = joinpath(Sys.BINDIR, Base.LIBEXECDIR, "7z.exe")
        else
          const exe7z = joinpath(Sys.BINDIR, "7z.exe")
        end
        unpack_cmd = pipeline(`$exe7z x $fop_gz -y -so`,`$exe7z x -si -y -ttar -o$tdeps`)
    end
    run(unpack_cmd)
end
