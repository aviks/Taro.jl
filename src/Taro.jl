module Taro

using JavaCall

tika_jar = joinpath(Pkg.dir(), "Taro", "deps", "tika-app-1.4.jar")

JavaCall.addClassPath(tika_jar)
JavaCall.addOpts("-Xmx256M")
JavaCall.addOpts("-Djava.awt.headless=true")

init() = JavaCall.init()

function extract(filename::String)
	JavaCall.assertloaded()
	File = @jvimport java.io.File
	f=File((JString,), filename)
	FileInputStream = @jvimport java.io.FileInputStream
	InputStream = @jvimport java.io.InputStream
	is = FileInputStream((File,), f)
	Metadata = @jvimport org.apache.tika.metadata.Metadata
	BodyContentHandler = @jvimport org.apache.tika.sax.BodyContentHandler
	AutoDetectParser = @jvimport org.apache.tika.parser.AutoDetectParser
	Tika = @jvimport org.apache.tika.Tika
	tika = Tika((),)
	mimeType = jcall(tika, "detect",JString, (File,), f) 

	metadata=Metadata((),)
	ch=BodyContentHandler((),)
	parser=AutoDetectParser((),)

	jcall(metadata, "set", Void, (JString, JString), "Content-Type", mimeType)
	ParseContext = @jvimport org.apache.tika.parser.ParseContext
	pc = ParseContext((),)
	ContentHandler = @jvimport org.xml.sax.ContentHandler
	jcall(parser, "parse", Void, (InputStream, ContentHandler, Metadata, ParseContext), is, ch, metadata, pc)
	nm = jcall(metadata, "names", Array{JString,1}, (),)
    nm = map(bytestring, nm)
    vs=Array(String, length(nm))
    for i in 1:length(nm)
        vs[i] = jcall(metadata, "get", JString, (JString,), nm[i])
    end

    body = jcall(ch, "toString", JString, (),)

    return Dict(nm, vs) , body

end

end # module
