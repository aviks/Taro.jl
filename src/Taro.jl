module Taro

using JavaCall
using DataFrames
using DataArrays

tika_jar = joinpath(dirname(@__FILE__), "..", "deps", "tika-app-1.17.jar")
fop_lib = joinpath(dirname(@__FILE__), "..", "deps", "fop-2.0", "lib", "*")
fop_jar = joinpath(dirname(@__FILE__), "..", "deps", "fop-2.0", "build", "fop.jar")

JavaCall.addClassPath(tika_jar)
JavaCall.addClassPath(fop_lib)
JavaCall.addClassPath(fop_jar)


JavaCall.addOpts("-Xmx256M")
JavaCall.addOpts("-Djava.awt.headless=true")

init() = JavaCall.init()
"""
    extract(filename::AbstractString; unsafe = false)

Extract raw text from documents, using Apache Tika.
Returns a Dict of metadata name value pairs, and a String with the text of the document.

    `filename`: path of file to read. relative to current directory, or absolute
    `unsafe` : If set to true, the full contents of the file is read. If false, returned string is capped at 100 000 characters.
"""
function extract(filename::AbstractString; unsafe = false)
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
	ch = unsafe ? BodyContentHandler((jint,),jint(-1)) : BodyContentHandler((),)
	parser=AutoDetectParser((),)

	jcall(metadata, "set", Void, (JString, JString), "Content-Type", mimeType)
	ParseContext = @jimport org.apache.tika.parser.ParseContext
	pc = ParseContext((),)
	ContentHandler = @jimport org.xml.sax.ContentHandler
	jcall(parser, "parse", Void, (InputStream, ContentHandler, Metadata, ParseContext), is, ch, metadata, pc)
	nm = jcall(metadata, "names", Array{JString,1}, (),)
    nm = map(unsafe_string, nm)
    vs=Array{String}(length(nm))
    for i in 1:length(nm)
        vs[i] = jcall(metadata, "get", JString, (JString,), nm[i])
    end

    body = jcall(ch, "toString", JString, (),)

    return Dict(zip(nm, vs)) , body

end



include("hssf.jl")
include("fop.jl")


end # module
