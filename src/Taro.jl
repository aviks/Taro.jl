module Taro

using JavaCall
using DataFrames
using DataArrays

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


const CELL_TYPE_NUMERIC = 0;
const CELL_TYPE_STRING = 1;
const CELL_TYPE_FORMULA = 2;
const CELL_TYPE_BLANK = 3;
const CELL_TYPE_BOOLEAN = 4;
const CELL_TYPE_ERROR = 5;

immutable ParseOptions{S <: ByteString, T <: ByteString}
    header::Bool
    separator::Char
    quotemark::Vector{Char}
    decimal::Char
    nastrings::Vector{S}
    truestrings::Vector{S}
    falsestrings::Vector{S}
    makefactors::Bool
    colnames::Vector{T}
    cleannames::Bool
    coltypes::Vector{Any}
    allowcomments::Bool
    commentmark::Char
    ignorepadding::Bool
    skipstart::Int
    skiprows::Vector{Int}
    skipblanks::Bool
    encoding::Symbol
    allowescapes::Bool
end

function readxl(filename::String, sheet::String, range::String; 
				   header::Bool = true,
                   separator::Char = ',',
                   quotemark::Vector{Char} = ['"'],
                   decimal::Char = '.',
                   nastrings::Vector = ASCIIString["", "NA"],
                   truestrings::Vector = ASCIIString["T", "t", "TRUE", "true"],
                   falsestrings::Vector = ASCIIString["F", "f", "FALSE", "false"],
                   makefactors::Bool = false,
                   nrows::Int = -1,
                   colnames::Vector = UTF8String[],
                   cleannames::Bool = false,
                   coltypes::Vector{Any} = Any[],
                   allowcomments::Bool = false,
                   commentmark::Char = '#',
                   ignorepadding::Bool = true,
                   skipstart::Int = 0,
                   skiprows::Vector{Int} = Int[],
                   skipblanks::Bool = true,
                   encoding::Symbol = :utf8,
                   allowescapes::Bool = false)

		
		# Set parsing options
    o = ParseOptions(header, separator, quotemark, decimal,
                     nastrings, truestrings, falsestrings,
                     makefactors, colnames, cleannames, coltypes,
                     allowcomments, commentmark, ignorepadding,
                     skipstart, skiprows, skipblanks, encoding,
                     allowescapes)

     r=r"([A-Za-z]*)(\d*):([A-Za-z]*)(\d*)"
     m=match(r, range)
     startrow=int(m.captures[2])-1
     startcol=colnum(m.captures[1])
     endrow=int(m.captures[4])-1
     endcol=colnum(m.captures[3])

     if (startrow > endrow ) || (startcol>endcol)
     	error("Please provide rectangular region from top left to bottom right corner")
     end

    readxl(filename, sheet, startrow, startcol, endrow, endcol, o)
end

function readxl(filename::String, sheetname::String, startrow::Int, startcol::Int, endrow::Int, endcol::Int, o )
	println("sr: $startrow sc: $startcol er: $endrow ec: $endcol")
	JavaCall.assertloaded()
	File = @jvimport java.io.File
	f=File((JString,), filename)
	WorkbookFactory = @jvimport org.apache.poi.ss.usermodel.WorkbookFactory
	Workbook = @jvimport org.apache.poi.ss.usermodel.Workbook
	Sheet = @jvimport org.apache.poi.ss.usermodel.Sheet
	Row = @jvimport org.apache.poi.ss.usermodel.Row
	Cell = @jvimport org.apache.poi.ss.usermodel.Cell

	book = jcall(WorkbookFactory, "create", Workbook, (File,), f)
	sheet = jcall(book, "getSheet", Sheet, (JString,), sheetname) 


	rows = endrow-startrow +1
	cols = endcol-startcol+1
	columns = Array(Any, cols)
	for j in startcol:endcol 
		values = Array(Any, rows)
		missing = falses(rows)
		for i in startrow:endrow
			row = jcall(sheet, "getRow", Row, (jint,), i)
			if isnull(row); missing[i-startrow+1]=true ; continue; end 
			cell = jcall(row, "getCell", Cell, (jint,), j)
			if isnull(cell); missing[i-startrow+1]=true ; continue; end
			celltype = jcall(cell, "getCellType", jint, (),)
			if celltype == CELL_TYPE_FORMULA
				celltype = jcall(cell, "getCachedFormulaResultType", jint, (),)
			end

			if celltype == CELL_TYPE_BLANK || celltype == CELL_TYPE_ERROR
				missing[i-startrow+1]=true 
			elseif celltype == CELL_TYPE_BOOLEAN
				values[i-startrow+1] = (jcall(cell, "getBooleanCellValue", jboolean, (),) == JavaCall.JNI_TRUE) 
			elseif celltype == CELL_TYPE_NUMERIC
				values[i-startrow+1] = jcall(cell, "getNumericCellValue", jdouble, (),)
			elseif celltype == CELL_TYPE_STRING
				values[i-startrow+1] = jcall(cell, "getStringCellValue", JString, (),)
			else 
				warn("Unknown Cell Type")
				missing[i-startrow+1]=true
			end

		end
		columns[j-startcol+1] = DataArray(values, missing)

	end
	if isempty(o.colnames)
        return DataFrame(columns, DataFrames.generate_column_names(cols))
    else
        return DataFrame(columns, o.colnames)
    end
end

function colnum(col::String)
	cl=uppercase(col)
	r=0
	for c in cl
		r = (r * 26) + (c - 'A' + 1)
	end
	return r-1
end



end # module
