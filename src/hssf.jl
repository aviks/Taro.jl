#Routines related to reading and writing Excel files uing Apache POI

export Workbook, getSheet, createSheet, getRow, createRow, getCell, createCell,
    getExcelDate, fromExcelDate, getCellType, isCellDateFormatted, setCellValue,
    getCellValue, setCellFormula, getCellFormula, createCellStyle, setCellStyle,
    setDataFormat, readxl, writexl

const CELL_TYPE_NUMERIC = 0;
const CELL_TYPE_STRING = 1;
const CELL_TYPE_FORMULA = 2;
const CELL_TYPE_BLANK = 3;
const CELL_TYPE_BOOLEAN = 4;
const CELL_TYPE_ERROR = 5;

"""
An excel Workbook, representing a single file. Wrapper around  the Java class
`org.apache.poi.ss.usermodel.Workbook`. Constructors of this types are used to
read existing files, or create new ones.
"""
const Workbook = JavaObject{Symbol("org.apache.poi.ss.usermodel.Workbook")}

"""
An excel Sheet, contained within a workbook. Wrapper around the Java class
`org.apache.poi.ss.usermodel.Sheet`.
"""
const Sheet = JavaObject{Symbol("org.apache.poi.ss.usermodel.Sheet")}

"A row in a sheet. Contains cells"
const Row = JavaObject{Symbol("org.apache.poi.ss.usermodel.Row")}

"""A cell within an excel sheet. Most operations to get or set values occur
on a cell. Wrapper for Java class `org.apache.poi.ss.usermodel.Cell`
"""
const Cell = JavaObject{Symbol("org.apache.poi.ss.usermodel.Cell")}

"A Cell style. Wrapper for Java class `org.apache.poi.ss.usermodel.CellStyle`"
const CellStyle = JavaObject{Symbol("org.apache.poi.ss.usermodel.CellStyle")}
const DataFormat = JavaObject{Symbol("org.apache.poi.ss.usermodel.DataFormat")}


jFile = @jimport java.io.File

immutable ParseOptions{S <: AbstractString}
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

"""
Read tabular data out of an excel file into a Julia Dataframe. This is similar to the
`readtable` function in the Dataframes package that reads a CSV file into a Dataframe.

The function returns a dataframe from the contents of an MS Excel file.
The sheet and region containing the data should be specified.
By default, a header row is expected, which must consist only of strings.
The `header` keyword argument should be set to `false` if no header is present in the data.

    filename : path of excel file (.xls or .xlsx)
    sheet : sheet name or number (0-based).
        Can be omitted, in which case the first sheet (index `0`) in the workbook is selected.
    range : string containing an excel range to read. eg. B4:D45

Optional Arguments : similar to `Dataframes.readtable`.
```
header::Bool = true
nastrings::Vector = ASCIIString["", "NA"]
truestrings::Vector = ASCIIString["T", "t", "TRUE", "true"]
falsestrings::Vector = ASCIIString["F", "f", "FALSE", "false"]
colnames::Vector = Symbol[]
coltypes::Vector{Any} = Any[]
skipstart::Int = 0
skiprows::Vector{Int} = Int[]
skipblanks::Bool = true
```

"""
function readxl(filename::AbstractString, sheet, range::AbstractString;
				   header::Bool = true,
                   nastrings::Vector = ["", "NA"],
                   truestrings::Vector = ["T", "t", "TRUE", "true"],
                   falsestrings::Vector = ["F", "f", "FALSE", "false"],
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

"""
    getSheet(book::Workbook, sheet)

Return the specified sheet from the workbook.  sheet can be specified as a name (string) or number (0-indexed)
"""
getSheet(book::Workbook , sheetName::AbstractString) = jcall(book, "getSheet", Sheet, (JString,), sheetName)
getSheet(book::Workbook , sheetNum::Integer) = jcall(book, "getSheetAt", Sheet, (jint,), sheetNum)
getSheetAt(book::Workbook, sheetNum::Integer) = getSheet(book, sheetNum)


function readxl(filename::AbstractString, sheetname, startrow::Int, startcol::Int, endrow::Int, endcol::Int, o )
	JavaCall.assertloaded()
    book = Workbook(filename)
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
			warn("Tried to read column headers, but failed. Set 'headers=false' if you do not have headers")
			resize!(o.colnames, 0)
		end
	end

	rows = endrow-startrow +1
	columns = Array{Any}(cols)
	for j in startcol:endcol
		values = Array{Any}(rows)
		missing = falses(rows)
		for i in startrow:endrow
			row = getRow(sheet, i)
			if isnull(row); missing[i-startrow+1]=true ; continue; end
			cell = getCell(row, j)
			if isnull(cell); missing[i-startrow+1]=true ; continue; end

            value = getCellValue(cell)
			if value == nothing || value in o.nastrings
				missing[i-startrow+1]=true
			elseif value in o.truestrings
				values[i-startrow+1] = true
			elseif value in o.falsestrings
				values[i-startrow+1] = false
			else
				values[i-startrow+1] = value
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

"""
    Workbook(filename::AbstractString)

Read an excel file and return a Workbook object
"""
function Workbook(filename::AbstractString)
	f=jFile((JString,), filename)
	WorkbookFactory = @jimport org.apache.poi.ss.usermodel.WorkbookFactory
	book = jcall(WorkbookFactory, "create", Workbook, (jFile,), f)
    if isnull(book) ; error("Unable to load Excel file: $filename"); end
    return book
end

"""
    Workbook()

Create a new Workbook in memory.
"""
function Workbook(x::Bool=true)
    local w
    if x
        w = @jimport(org.apache.poi.xssf.usermodel.XSSFWorkbook)(())
    else
        w = @jimport(org.apache.poi.hssf.usermodel.HSSFWorkbook)(())
    end
    return convert(Workbook, w)
end

"""
    createSheet(w::Workbook, s::AbstractString)

Create a new sheet in the workbook with the specified name.
"""
createSheet(w::Workbook, s::AbstractString) = jcall(w, "createSheet", Sheet, (JString,), s)
createRow(s::Sheet, r::Integer) = jcall(s, "createRow", Row, (jint,), r)
createCell(r::Row, c::Integer) = jcall(r, "createCell", Cell, (jint,), c)
getCell(row::Row, c::Integer) = jcall(row, "getCell", Cell, (jint,), c)
getRow(sheet::Sheet, r::Integer) = jcall(sheet, "getRow", Row, (jint,), r)

"""
    getCellType(cell::Cell)

Return the type of a cell:
CELL_TYPE_NUMERIC, CELL_TYPE_STRING, CELL_TYPE_FORMULA, CELL_TYPE_BLANK, CELL_TYPE_BOOLEAN, CELL_TYPE_ERROR
"""
getCellType(cell::Cell) = jcall(cell, "getCellType", jint, (),)

getCachedFormulaResultType(cell::Cell) = jcall(cell, "getCachedFormulaResultType", jint, (),)
getBooleanCellValue(cell::Cell) = jcall(cell, "getBooleanCellValue", jboolean, (),) == JavaCall.JNI_TRUE
getNumericCellValue(cell::Cell) = jcall(cell, "getNumericCellValue", jdouble, (),)
getStringCellValue(cell::Cell) = jcall(cell, "getStringCellValue", JString, (),)

"""
    getCellFormula(cell::Cell)
"""
getCellFormula(cell::Cell) = jcall(cell, "getCellFormula", JString, (),)

"""
    getCellValue(cell::Cell)

Return the contents of a Excel cell.

A string or a float value is returned based on the type of the contents of the cell.
If a cell is recognised as a being formatted like a date, a Julia DateTime object is returned.
This function therefore is *not* type stable. For formulas, the last evaluated value
of the cell is returned.

Note that the dates are stored internally within Excel as floats, and the recognition as
a date is heuristic.

If a cell contains an error value, or is empty, `nothing` is returned.
"""
function getCellValue(cell::Cell)
    celltype = getCellType(cell)
    if celltype == CELL_TYPE_FORMULA
        celltype = getCachedFormulaResultType(cell)
    end
    if celltype == CELL_TYPE_BLANK || celltype == CELL_TYPE_ERROR
        return nothing
    elseif celltype == CELL_TYPE_BOOLEAN
        return  getBooleanCellValue(cell)
    elseif celltype == CELL_TYPE_NUMERIC
        if isCellDateFormatted(cell)
            return fromExcelDate(getNumericCellValue(cell))
        else
            return getNumericCellValue(cell)
        end
    elseif celltype == CELL_TYPE_STRING
        return getStringCellValue(cell)
    else
        warn("Unknown Cell Type")
        return nothing
    end
end

"""
    write(filename::AbstractString, w::Workbook)

Write a workbook to disk.
"""
function Base.write(filename::AbstractString, w::Workbook)
    fos = @jimport(java.io.FileOutputStream)((JString,), filename)
    jcall(w, "write", Void, (@jimport(java.io.OutputStream),), fos)
    jcall(fos, "close", Void,())
end

"""
    setCellValue(c::Cell, x)

Set the value of an excel cell. The value can be a string, a real number, or a Date or DateTime.
"""
setCellValue(c::Cell, s::AbstractString) = jcall(c, "setCellValue", Void, (JString,), s)
setCellValue(c::Cell, n::Real) = jcall(c, "setCellValue", Void, (jdouble,), n)
setCellValue(c::Cell, d::Union{Date, DateTime}) = jcall(c, "setCellValue", Void, (jdouble, ), getExcelDate(d))

"""
    setCellFormula(c::Cell, formula::AbstractString)

Set a formula as a value to an Excel cell.

The formula string should be what you would expect to enter in excel, but without the *+*.
For example: "A2+2*B2" , "sin(A2)" , "some_user_defined_formula(B2)"
Note that the formula will be evaluated only when the file is actually opened in Excel.
"""
setCellFormula(c::Cell, s::AbstractString) = jcall(c, "setCellFormula", Void, (JString, ), s)

"""
    setCellStyle(cell:Cell, style::CellStyle)

Set a style to a cell. The CellStyle object must be created from the workbook
"""
setCellStyle(cell::Cell, style::CellStyle) = jcall(cell, "setCellStyle", Void, (CellStyle, ), style)

"create a new cell style from a workbook, prior to setting it on a cell"
createCellStyle(w::Workbook) = jcall(w, "createCellStyle", CellStyle, (),)

"""
    setDataFormat(w::Workbook, style::CellStyle, format::AbstractString)

Set a dataformat on a CellStyle. Need the workbook to tie everything together
"""
function setDataFormat(w::Workbook, style::CellStyle, f::AbstractString)
    creationHelper = jcall(w, "getCreationHelper", @jimport(org.apache.poi.ss.usermodel.CreationHelper), (), )
    dataFormat = jcall(creationHelper, "createDataFormat", DataFormat, (), )
    format = jcall(dataFormat, "getFormat", jshort, (JString, ), f)
    jcall(style, "setDataFormat", Void, (jshort, ), format)
end

### Excel Date related functions
global const SECONDS_PER_MINUTE = 60
global const MINUTES_PER_HOUR = 60
global const HOURS_PER_DAY = 24
global const SECONDS_PER_DAY = (HOURS_PER_DAY * MINUTES_PER_HOUR * SECONDS_PER_MINUTE)
global const DAY_MILLISECONDS = SECONDS_PER_DAY * 1000

"""
    fromExcelDate(date::Number; use1904windowing=false, roundtoSeconds=false)

Convert an Excel style date to a Julia DateTime object.

Excel stores dates and times as a floating point number representing the
fractional days since 1/1/1900. If `use1904windowing` is true, the epoch is 1/1/1904,
which is used in some older Excel for Mac versions. If `roundtoSeconds` is true,
the millisecond part of the time is discarded.
"""
function fromExcelDate(date::Number; use1904windowing=false, roundtoSeconds=false)
      wholeDays = floor(Int, date)
      millisInDay = round(Int, (date-wholeDays)*DAY_MILLISECONDS)
      startYear = 1900
      dayAdjust = -1 #Excel thinks 2/29/1900 is a valid date, which it isn't
      if (use1904windowing)
        startYear = 1904
        dayAdjust = 1 #// 1904 date windowing uses 1/2/1904 as the first day
      elseif (wholeDays < 61)
        dayAdjust = 0
      end

      d = DateTime(startYear, 1, 1)
      d = d+Dates.Day(wholeDays + dayAdjust - 1)
      if roundtoSeconds
        millisInDay = round(Int, millisInDay/1000)*1000
      end
      d = d + Dates.Millisecond(millisInDay)
      return d
end

"""
    getExcelDate(date::DateTime, use1904windowing::Bool = false)

Convert a Julia DateTime object into an Excel Date. The result will be a floating
point number representing days since 1/1/1900. The time from midnight will be the
fractional part of the number. If `use1904windowing` is true, the epoch is 1/1/1904,
which is used in some older Excel for Mac versions.
"""
function getExcelDate(date::DateTime, use1904windowing::Bool=false)  #->Float64
        if (!use1904windowing && Dates.year(date) < 1900)  || (use1904windowing && Dates.year(date) < 1904)
            error("Invalid Date -- cannot convert to excel")
        end

        fraction = (((Dates.hour(date) * 60
                             + Dates.minute(date)
                            ) * 60 + Dates.second(date)
                           ) * 1000 + Dates.millisecond(date)
                          ) / DAY_MILLISECONDS;
        dayStart = DateTime(Dates.year(date), Dates.month(date), Dates.day(date))
        yearStart = use1904windowing?1904:1900
        value = Int64(Dates.value(Dates.Day(dayStart - DateTime(yearStart, 1, 1)))) + 1

        if (!use1904windowing && value >= 60)
            value+=1
        elseif (use1904windowing)
            value-=1;
        end

        return value+fraction
end
getExcelDate(date::Date, use1904windowing::Bool=false) = getExcelDate(DateTime(date), use1904windowing)

"""
    isCellDateFormatted(cell::Cell)

Return true if the format applied to the cell looks like a date.

This is a heuristic, and not guaranteed to be correct.
"""
isCellDateFormatted(cell::Cell) =
     jcall(@jimport(org.apache.poi.ss.usermodel.DateUtil), "isCellDateFormatted", jboolean, (Cell,), cell) ==
         JavaCall.JNI_TRUE

"write a vector of dataframes to an xlsx file"
"""
Write a vector of Julia Dataframes to an Excel file, each representing an Excel Sheet.

    filename : path of excel file (.xls or .xlsx)
    dfs : Vector{DataFrame} with each DataFrame representing a separate Excel Sheet

Optional Arguments.
```
headers = String[] a string vector of same length as dfs, to add a first line before the sheet is written
sheetnames = String[]
append::Bool = true is supposed to append the DataFrame sheets to an existing excel file, but currently fails often.
    For now, it is better to make sure no such file exists before using.
```

"""
function writexl(filename::AbstractString, dfs::Vector{T}; headers=String[], sheetnames=String[], append::Bool=true) where {T <: DataFrame}
  try
    if append && isfile(filename)
      w=Workbook(filename)
    else
      w=Workbook()
    end
    for d=1:length(dfs)
      df=dfs[d]
      sheetname = isempty(sheetnames) ? "df$d" : sheetnames[d]
      header = isempty(headers) ? "" : headers[d]
      info("adding $sheetname sheet $header...")
      s=createSheet(w, sheetname)
      nrows,ncols = size(df)
      colnames=map(string,names(df))
      headerlines = zero(Integer)
      if header != ""
        r=createRow(s, 0)
        c=createCell(r, 0)
        setCellValue(c, header)
        headerlines = 1
      end
      r=createRow(s, headerlines)
      for j=1:ncols
        if !contains(colnames[j],"spacer")
          c=createCell(r, j-1)
          setCellValue(c, colnames[j])
        end
      end
      for i=1:nrows
        r=createRow(s, headerlines+i)
        for j=1:ncols
          cellvalue = df[i,j]
          if !any(isna(df[i,j]))
            if typeof(cellvalue) == Symbol
              cellvalue = string(cellvalue)
            end
            c=createCell(r, j-1)
            setCellValue(c, cellvalue)
          end
        end
      end
    end
    write(filename, w)
    info("wrote all dataframes to $filename.")
  catch e
    warn("failed to writexl to $filename")
    warn("due to exception: $e")
  end
end
