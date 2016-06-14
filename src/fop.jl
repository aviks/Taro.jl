
"""
    Taro.fo(inputFoFileName::String, outputPDFFileName::String)

Convert the input `fo` file to a PDF.
"""
function fo(input::AbstractString, output::AbstractString)

    FopFactory = @jimport org.apache.fop.apps.FopFactory
    Fop = @jimport org.apache.fop.apps.Fop

    URI = @jimport java.net.URI
    File = @jimport java.io.File
    FileOutputStream = @jimport java.io.FileOutputStream
    BufferedOutputStream = @jimport java.io.BufferedOutputStream
    OutputStream = @jimport java.io.OutputStream

    TransformerFactory = @jimport javax.xml.transform.TransformerFactory
    Transformer = @jimport javax.xml.transform.Transformer
    Source = @jimport javax.xml.transform.Source
    StreamSource = @jimport javax.xml.transform.stream.StreamSource
    Result = @jimport javax.xml.transform.Result
    SAXResult = @jimport javax.xml.transform.sax.SAXResult

    baseURI = jcall( File((JString,), "."), "toURI", URI, ())

    fopFactory = jcall(FopFactory, "newInstance", FopFactory, (URI,), baseURI )

    inputFile = File((JString,), input)
    outputFile = File((JString,), output)
    fout = FileOutputStream( (File,), outputFile)
    bout = BufferedOutputStream( (OutputStream,), fout)
    fop = jcall(fopFactory, "newFop", Fop, (JString, OutputStream), "application/pdf", bout)

    transformerFactory = jcall(TransformerFactory, "newInstance", TransformerFactory, ())
    transformer = jcall(transformerFactory, "newTransformer", Transformer, ())
    src = StreamSource((File,), inputFile)
    handler = jcall(fop, "getDefaultHandler", @jimport(org.xml.sax.helpers.DefaultHandler), ())
    res = SAXResult((@jimport(org.xml.sax.ContentHandler),), handler)

    jcall(transformer, "transform", Void, (Source, Result), src, res)
    jcall(bout, "close", Void, ())
end
