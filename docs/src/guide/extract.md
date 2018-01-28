#Data Extraction

Taro includes a few high level functions that extract data from various document formats.

##Text extraction

The [`Taro.extract`](@ref) method retrieves document metadata and the body text of a document,
using [Apache Tika](https://tika.apache.org/). Formats [supported by Tika](https://tika.apache.org/1.17/formats.html)
include MS Office and Open Office documents, as well as PDF files.

The function return a Tuple of a Dict and String. The Dict contains name/value pairs of various metadata from the document, while the string contains the body text of the document.

```@repl
using Taro # hide
testfile = joinpath(Pkg.dir(),"Taro","test","WhyJulia.docx");
meta, text = Taro.extract(testfile);
meta["Last-Save-Date"]
typeof(text)
text[1:53]
```
## Read Excel files into a DataFrame

The [`Taro.readxl`](@ref) method reads a rectangular region from an excel sheet, and
returns a [Dataframe](http://juliadata.github.io/DataFrames.jl/latest/man/getting_started.html#The-DataFrame-Type-1).
This function takes as an input parameter the name and path of the Excel file to be read. A sheet name (or number) can optionally be supplied. If no sheet information is given, the first sheet (index 0) is read. Finally, this
function is provided with the rectangular region from which data is extracted. This region is specified as an excel
range.

This function is similar to, and inspired by, the [CSV.read/DataFrames.readtable](http://juliadata.github.io/CSV.jl/latest/#CSV.read) function in CSV/DataFrames.

```@repl
using Taro # hide
testfile = joinpath(Pkg.dir(),"Taro","test","df-test.xlsx");
Taro.readxl(testfile, "Sheet1", "B2:F10")
Taro.readxl(testfile, "Sheet1", "B3:F10"; header=false)
Taro.readxl(testfile, "Sheet1", "B3:F10"; header=false, nastrings=[" "])
```
