#Routines related to reading and writing Excel files uing Apache POI

const CELL_TYPE_NUMERIC = 0;
const CELL_TYPE_STRING = 1;
const CELL_TYPE_FORMULA = 2;
const CELL_TYPE_BLANK = 3;
const CELL_TYPE_BOOLEAN = 4;
const CELL_TYPE_ERROR = 5;

immutable ParseOptions{S <: ByteString}
    header::Bool
    nastrings::Vector{S}
    truestrings::Vector{S}
    falsestrings::Vector{S}
    colnames::Vector{Symbol}
    coltypes::Vector{Any}
    skipstart::Int
    skiprows::Vector{Int}
    skipblanks::Bool
end

#Cant use optional arguments since our API was already set with sheet as the second param.
readxl(filename::AbstractString, range::AbstractString;  opts...) = readxl(filename, 0, range; opts...)

function readxl(filename::AbstractString, sheet, range::AbstractString;
				   header::Bool = true,
                   nastrings::Vector = ASCIIString["", "NA"],
                   truestrings::Vector = ASCIIString["T", "t", "TRUE", "true"],
                   falsestrings::Vector = ASCIIString["F", "f", "FALSE", "false"],
                   colnames::Vector = Symbol[],
                   coltypes::Vector{Any} = Any[],
                   skipstart::Int = 0,
                   skiprows::Vector{Int} = Int[],
                   skipblanks::Bool = true)


		# Set parsing options
    o = ParseOptions(header,
                     nastrings, truestrings, falsestrings,
                     colnames, coltypes,
                     skipstart, skiprows, skipblanks)

     r=r"([A-Za-z]*)(\d*):([A-Za-z]*)(\d*)"
     m=match(r, range)
     startrow=parse(Int, m.captures[2])-1
     startcol=colnum(m.captures[1])
     endrow=parse(Int, m.captures[4])-1
     endcol=colnum(m.captures[3])

     if (startrow > endrow ) || (startcol>endcol)
     	error("Please provide rectangular region from top left to bottom right corner")
     end

    readxl(filename, sheet, startrow, startcol, endrow, endcol, o)
end

function getSheet(book::JavaObject , sheetName::AbstractString)
    Sheet = @jimport org.apache.poi.ss.usermodel.Sheet
    jcall(book, "getSheet", Sheet, (JString,), sheetName)
end

function getSheet(book::JavaObject , sheetNum::Integer)
    Sheet = @jimport org.apache.poi.ss.usermodel.Sheet
    jcall(book, "getSheetAt", Sheet, (jint,), sheetNum)
end



function readxl(filename::AbstractString, sheetname, startrow::Int, startcol::Int, endrow::Int, endcol::Int, o )
	JavaCall.assertloaded()
	File = @jimport java.io.File
	f=File((JString,), filename)
	WorkbookFactory = @jimport org.apache.poi.ss.usermodel.WorkbookFactory
	Workbook = @jimport org.apache.poi.ss.usermodel.Workbook
	Sheet = @jimport org.apache.poi.ss.usermodel.Sheet
	Row = @jimport org.apache.poi.ss.usermodel.Row
	Cell = @jimport org.apache.poi.ss.usermodel.Cell

	book = jcall(WorkbookFactory, "create", Workbook, (File,), f)
    if isnull(book) ; error("Unable to load Excel file: $filename"); end
	sheet = getSheet(book, sheetname)
    if isnull(sheet); error("Unable to load sheet: $sheetname in file: $filename"); end
    cols = endcol-startcol+1

	if o.header
		try
			row = jcall(sheet, "getRow", Row, (jint,), startrow)
			if !isnull(row)
				resize!(o.colnames,cols)
				for j in startcol:endcol
					cell = jcall(row, "getCell", Cell, (jint,), j)
					if !isnull(cell)
						o.colnames[j-startcol+1] = DataFrames.makeidentifier(jcall(cell, "getStringCellValue", JString, (),))
					end
				end
			end
			startrow = startrow+1
		catch
			warn("Tried to read column headers, but failed. Set 'headers=false' if you don't have headers")
			resize!(o.colnames, 0)
		end
	end

	rows = endrow-startrow +1
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
				value = jcall(cell, "getStringCellValue", JString, (),)
				if value in o.nastrings
					missing[i-startrow+1]=true
				elseif value in o.truestrings
					values[i-startrow+1] = true
				elseif value in o.falsestrings
					values[i-startrow+1] = false
				else
					values[i-startrow+1] = value
				end
			else
				warn("Unknown Cell Type")
				missing[i-startrow+1]=true
			end

		end
		columns[j-startcol+1] = DataArray(values, missing)

	end
	if isempty(o.colnames)
        return DataFrame(columns, DataFrames.gennames(cols))
    else
        return DataFrame(columns, o.colnames)
    end
end

function colnum(col::AbstractString)
	cl=uppercase(col)
	r=0
	for c in cl
		r = (r * 26) + (c - 'A' + 1)
	end
	return r-1
end
