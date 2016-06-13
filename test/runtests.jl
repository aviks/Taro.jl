using Base.Test
using Taro

tdir = joinpath(Pkg.dir("Taro"),"test")
Taro.init()

meta, body=Taro.extract("$(joinpath(tdir,"WhyJulia.docx"))")
@test length(keys(meta)) > 40
@test length(body)>2900


meta, body=Taro.extract("$(joinpath(tdir,"WhyJulia.pdf"))")
@test length(keys(meta)) > 30
@test length(body)>3000

df=Taro.readxl("$(joinpath(tdir,"df-test.xlsx"))","Sheet1", "B2:F10")
@test 5==length(df)
@test 8==length(df[1])

#Test Date Routines
t=now()
@assert fromExcelDate(getExcelDate(t)) - t == Dates.Millisecond(0)

#Workbook
w=Workbook()
s=createSheet(w, "runtests")
r=createRow(s, 1)
c=createCell(r, 1)
setCellValue(c, "A String")
c=createCell(r, 2)
setCellValue(c, 25)
c=createCell(r, 3)
setCellValue(c, 2.5)
c=createCell(r, 4)
setCellValue(c, t)
c=createCell(r, 5)
setCellFormula(c, "C2+D2")
write(Pkg.dir("Taro", "test", "write-tests.xlsx"), w)

#read the file we just wrote
w2=Workbook(Pkg.dir("Taro", "test", "write-tests.xlsx"))
s2 = getSheet(w2, "runtests")
r2 = getRow(s2, 1)
c2 = getCell(r2, 1)
@assert getCellValue(c2) == "A String"
c2 = getCell(r2, 2)
@assert getCellValue(c2) == 25
c2 = getCell(r2, 3)
@assert getCellValue(c2) == 2.5
c2 = getCell(r2, 4)
@assert fromExcelDate(getCellValue(c2)) == t
c2 = getCell(r2, 5)
@assert getCellFormula(c2) == "C2+D2"



try
    rm("$(joinpath(tdir,"simple.pdf"))")
    rm(Pkg.dir("Taro", "test", "write-tests.xlsx"))
catch
end

@assert !isfile("$(joinpath(tdir,"simple.pdf"))")
Taro.fo(joinpath(tdir, "simple.fo"), joinpath(tdir,"simple.pdf"))
@assert isfile("$(joinpath(tdir,"simple.pdf"))")
JavaCall.destroy()
