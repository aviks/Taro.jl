module Taro

using JavaCall
using DataFrames
using DataArrays
using Compat

tika_jar = joinpath(dirname(@__FILE__), "..", "deps", "tika-app-1.10.jar")
avalon_jar = joinpath(dirname(@__FILE__), "..", "deps", "fop-2.0", "lib", "avalon-framework-4.2.0.jar")
batik_jar = joinpath(dirname(@__FILE__), "..", "deps", "fop-2.0", "lib", "batik-all-1.8.jar")
commons_io_jar = joinpath(dirname(@__FILE__), "..", "deps", "fop-2.0", "lib", "commons-io-1.3.1.jar")
commons_logging_jar = joinpath(dirname(@__FILE__), "..", "deps", "fop-2.0", "lib", "commons-logging-1.0.4.jar")
fontbox_jar = joinpath(dirname(@__FILE__), "..", "deps", "fop-2.0", "lib", "fontbox-1.8.5.jar")
serializer_jar = joinpath(dirname(@__FILE__), "..", "deps", "fop-2.0", "lib", "serializer-2.7.0.jar")
xalan_jar = joinpath(dirname(@__FILE__), "..", "deps", "fop-2.0", "lib", "xalan-2.7.0.jar")
xerces_jar = joinpath(dirname(@__FILE__), "..", "deps", "fop-2.0", "lib", "xercesImpl-2.7.1.jar")
xml_apis_jar = joinpath(dirname(@__FILE__), "..", "deps", "fop-2.0", "lib", "xml-apis-1.3.04.jar")
xml_apis_ext_jar = joinpath(dirname(@__FILE__), "..", "deps", "fop-2.0", "lib", "xml-apis-ext-1.3.04.jar")
xmlgraphics_common_jar = joinpath(dirname(@__FILE__), "..", "deps", "fop-2.0", "lib", "xmlgraphics-commons-2.0.1.jar")

fop_jar = joinpath(dirname(@__FILE__), "..", "deps", "fop-2.0", "build", "fop.jar")

JavaCall.addClassPath(tika_jar)
JavaCall.addClassPath(avalon_jar)
JavaCall.addClassPath(batik_jar)
JavaCall.addClassPath(commons_io_jar)
JavaCall.addClassPath(commons_logging_jar)
JavaCall.addClassPath(fontbox_jar)
JavaCall.addClassPath(serializer_jar)
JavaCall.addClassPath(xalan_jar)
JavaCall.addClassPath(xerces_jar)
JavaCall.addClassPath(xml_apis_jar)
JavaCall.addClassPath(xml_apis_ext_jar)
JavaCall.addClassPath(xmlgraphics_common_jar)
JavaCall.addClassPath(fop_jar)


JavaCall.addOpts("-Xmx256M")
JavaCall.addOpts("-Djava.awt.headless=true")

init() = JavaCall.init()
"""
    extract(filename::AbstractString)

Extract raw text from documents, using Apache Tika.
Returns a Dict of metadata name value pairs, and a String with the text of the document.

    filename: path of file to read. relative to current directory, or absolute
"""
function extract(filename::AbstractString)
	JavaCall.assertloaded()
	File = @jimport java.io.File
	f=File((JString,), filename)
	FileInputStream = @jimport java.io.FileInputStream
	InputStream = @jimport java.io.InputStream
	is = FileInputStream((File,), f)
	Metadata = @jimport org.apache.tika.metadata.Metadata
	BodyContentHandler = @jimport org.apache.tika.sax.BodyContentHandler
	AutoDetectParser = @jimport org.apache.tika.parser.AutoDetectParser
	Tika = @jimport org.apache.tika.Tika
	tika = Tika((),)
	mimeType = jcall(tika, "detect",JString, (File,), f)

	metadata=Metadata((),)
	ch=BodyContentHandler((),)
	parser=AutoDetectParser((),)

	jcall(metadata, "set", Void, (JString, JString), "Content-Type", mimeType)
	ParseContext = @jimport org.apache.tika.parser.ParseContext
	pc = ParseContext((),)
	ContentHandler = @jimport org.xml.sax.ContentHandler
	jcall(parser, "parse", Void, (InputStream, ContentHandler, Metadata, ParseContext), is, ch, metadata, pc)
	nm = jcall(metadata, "names", Array{JString,1}, (),)
    nm = map(unsafe_string, nm)
    vs=Array(AbstractString, length(nm))
    for i in 1:length(nm)
        vs[i] = jcall(metadata, "get", JString, (JString,), nm[i])
    end

    body = jcall(ch, "toString", JString, (),)

    return Dict(zip(nm, vs)) , body

end



include("hssf.jl")
include("fop.jl")


end # module
