# tika_jar = joinpath(tdeps, "tika-app-1.4.jar")
# if !isfile(tika_jar)
# 	info("    Downloading tika-app-1.4.jar from Maven Central")
# 	download("http://search.maven.org/remotecontent?filepath=org/apache/tika/tika-app/1.4/tika-app-1.4.jar", tika_jar)
# end

tdeps = joinpath(Pkg.dir("Taro"), "deps")
tika_jar = joinpath(tdeps, "tika-app-1.10.jar")
if !isfile(tika_jar)
    info("  Downloading tika-app-1.10.jar from Maven Central")
    download("http://search.maven.org/remotecontent?filepath=org/apache/tika/tika-app/1.10/tika-app-1.10.jar", tika_jar)
end


# avalon_api_jar = joinpath(tdeps, "avalon-framework-api-4.2.0.jar")
# if !isfile(avalon_api_jar)
#     info("    Downloading avalon-framework-api-4.2.0.jar from Maven Central")
#     download("http://search.maven.org/remotecontent?filepath=avalon-framework/avalon-framework-api/4.2.0/avalon-framework-api-4.2.0.jar", avalon_api_jar)
# end
# avalon_impl_jar = joinpath(tdeps, "avalon-framework-impl-4.2.0.jar")
# if !isfile(avalon_impl_jar)
#     info("    Downloading avalon-framework-impl-4.2.0.jar from Maven Central")
#     download("http://search.maven.org/remotecontent?filepath=avalon-framework/avalon-framework-impl/4.2.0/avalon-framework-impl-4.2.0.jar", avalon_impl_jar)
# end
# batik_jar = joinpath(tdeps, "batik-all-1.8pre-r1084380.jar")
# if !isfile(batik_jar)
#     info("    Downloading batik-all-1.8pre-r1084380.jar from Maven Central")
#     download("http://search.maven.org/remotecontent?filepath=org/codeartisans/thirdparties/swing/batik-all/1.8pre-r1084380/batik-all-1.8pre-r1084380.jar", batik_jar)
# end
# commons_io_jar = joinpath(tdeps, "commons-io-1.3.1.jar")
# if !isfile(commons_io_jar)
#     info("    Downloading commons-io-1.3.1.jar from Maven Central")
#     download("http://search.maven.org/remotecontent?filepath=commons-io/commons-io/1.3.1/commons-io-1.3.1.jar", commons_io_jar)
# end
# commons_logging_jar = joinpath(tdeps, "commons-logging-1.0.4.jar")
# if !isfile(commons_logging_jar)
#     info("    Downloading commons-logging-1.0.4.jar from Maven Central")
#     download("http://search.maven.org/remotecontent?filepath=commons-logging/commons-logging/1.0.4/commons-logging-1.0.4.jar", commons_logging_jar)
# end
# fontbox_jar = joinpath(tdeps, "fontbox-1.8.5.jar")
# if !isfile(fontbox_jar)
#     info("    Downloading fontbox-1.8.5.jar from Maven Central")
#     download("http://search.maven.org/remotecontent?filepath=org/apache/pdfbox/fontbox/1.8.5/fontbox-1.8.5.jar", fontbox_jar)
# end
# serializer_jar = joinpath(tdeps, "serializer-2.7.1.jar")
# if !isfile(serializer_jar)
#     info("    Downloading serializer-2.7.1.jar from Maven Central")
#     download("http://search.maven.org/remotecontent?filepath=xalan/serializer/2.7.1/serializer-2.7.1.jar", serializer_jar)
# end
# xalan_jar = joinpath(tdeps, "xalan-2.7.1.jar")
# if !isfile(xalan_jar)
#     info("    Downloading xalan-2.7.1.jar from Maven Central")
#     download("http://search.maven.org/remotecontent?filepath=xalan/xalan/2.7.1/xalan-2.7.1.jar", xalan_jar)
# end
# xerces_jar = joinpath(tdeps, "xercesImpl-2.7.1.jar")
# if !isfile(xerces_jar)
#     info("    Downloading xercesImpl-2.7.1.jar from Maven Central")
#     download("http://search.maven.org/remotecontent?filepath=xerces/xercesImpl/2.7.1/xercesImpl-2.7.1.jar", xerces_jar)
# end
# xml_apis_jar = joinpath(tdeps, "xml-apis-1.3.04.jar")
# if !isfile(xml_apis_jar)
#     info("    Downloading xml-apis-1.3.04.jar from Maven Central")
#     download("http://search.maven.org/remotecontent?filepath=xml-apis/xml-apis/1.3.04/xml-apis-1.3.04.jar", xml_apis_jar)
# end
# xml_apis_ext_jar = joinpath(tdeps, "xml-apis-ext-1.3.04.jar")
# if !isfile(xml_apis_ext_jar)
#     info("    Downloading xml-apis-ext-1.3.04.jar from Maven Central")
#     download("http://search.maven.org/remotecontent?filepath=xml-apis/xml-apis-ext/1.3.04/xml-apis-ext-1.3.04.jar", xml_apis_ext_jar)
# end
# xmlgraphics_common_jar = joinpath(tdeps, "xmlgraphics-commons-2.0.1.jar")
# if !isfile(xmlgraphics_common_jar)
#     info("    Downloading xmlgraphics-commons-2.0.1.jar from Maven Central")
#     download("http://search.maven.org/remotecontent?filepath=org/apache/xmlgraphics/xmlgraphics-commons/2.0.1/xmlgraphics-commons-2.0.1.jar", xmlgraphics_common_jar)
# end
# fop_jar = joinpath(tdeps, "fop-2.0.jar")
# if !isfile(fop_jar)
#     info("    Downloading fop-2.0.jar from Maven Central")
#     download("http://central.maven.org/maven2/org/apache/xmlgraphics/fop/2.0/fop-2.0.jar", fop_jar)
# end

fop_jar = joinpath(tdeps, "fop-2,0", "fop-2.0.jar")
fop_gz = joinpath(tdeps, "fop-2.0-bin.tar.gz")

if !isfile(fop_gz)
    info("  Downloading fop-2.0 binary from Apache OSUOSL Mirror")
    download("http://apache.osuosl.org/xmlgraphics/fop/binaries/fop-2.0-bin.tar.gz", fop_gz)
end
if !isfile(fop_jar)
    @unix_only unpack_cmd = `tar xzf $fop_gz --directory=$tdeps`
    @windows_only unpack_cmd = `7z x $fop_gz -y -so`|>`7z x -si -y -ttar -o$tdeps`
    run(unpack_cmd)
end
