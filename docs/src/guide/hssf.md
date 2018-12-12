# Read and Write Excel Files

The [`Taro.readxl`](@ref) function is a simple, high level method to read tabular data from Excel files into
a Julia DataFrames. 
Its counterpart, [`Taro.writexl`](@ref) is a simple, high level method to write a vector of DataFrames to an Excel file, each representing an Excel Sheet.
For more control over reading files cell by cell, and for creating or modifyting  excel files,  this package exposes functions to read, create and write workbooks, sheets, rows and cells.
The functions are modelled on the underlying POI API (converted to functional form), which in turn is based on the structure of an Excel file.

```@example
using Taro # hide
t=now()
w=Workbook()
s=createSheet(w, "runtests")
r=createRow(s, 1)
c=createCell(r, 1); setCellValue(c, "A String")
c=createCell(r, 2); setCellValue(c, 25)
c=createCell(r, 3); setCellValue(c, 2.5)
c=createCell(r, 4); setCellValue(c, t)
s=createCellStyle(w)
setDataFormat(w, s, "m/d/yy h:mm")
setCellStyle(c, s)
c=createCell(r, 5); setCellFormula(c, "C2+D2")
write(Pkg.dir("Taro", "test", "write-tests.xlsx"), w)
```

We can now read the file we just wrote, and verify the values we inserted.
```@repl
using Taro # hide
w2=Workbook(Pkg.dir("Taro", "test", "write-tests.xlsx"))
s2 = getSheet(w2, "runtests")
r2 = getRow(s2, 1)
c2 = getCell(r2, 1); getCellValue(c2)
c2 = getCell(r2, 2); getCellValue(c2)
c2 = getCell(r2, 3); getCellValue(c2)
c2 = getCell(r2, 4); getCellValue(c2)
c2 = getCell(r2, 5); getCellFormula(c2)
```
