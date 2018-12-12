using Test
using Taro
using Dates
using DataFrames
using JavaCall

tdir = dirname(@__FILE__)
Taro.init()

meta, body=Taro.extract("$(joinpath(tdir,"WhyJulia.docx"))")
@test length(keys(meta)) > 40
@test length(body)>2900


meta, body=Taro.extract("$(joinpath(tdir,"WhyJulia.pdf"))")
@test length(keys(meta)) > 30
@test length(body)>3000

nt=Taro.readxl("$(joinpath(tdir,"df-test.xlsx"))","Sheet1", "B2:F10")

df = DataFrame(nt)
@test 5==size(df,2)
@test 8==size(df, 1)

const writetestfile = "$(joinpath(tdir,"df-test-writexl.xlsx"))"

# specifying sheetnames
rm(writetestfile; force=true)
Taro.writexl(writetestfile, [df, df]; sheetnames=["t1", "t2"])
t1 = Taro.readxl(writetestfile,"t1","A1:E9")
@test hash(DataFrame(t1)) == hash(df)
t2 = Taro.readxl(writetestfile,"t2","A1:E9")
@test hash(DataFrame(t2)) == hash(df)
# TODO: figure out why appending to a file causes segfault
# Taro.writexl(writetestfile, [df]; append=true)
# t3 = Taro.readxl(writetestfile,2,"A1:E9")
# @test hash(t3) == hash(df)

# without specifying sheetnames
rm(writetestfile; force=true)
Taro.writexl(writetestfile, [df, df])
# Taro.writexl(writetestfile, [df]; sheetnames=["df3"], append=true)
t1 = Taro.readxl(writetestfile,0,"A1:E9")
@test hash(DataFrame(t1)) == hash(df)
t2 = Taro.readxl(writetestfile,1,"A1:E9")
@test hash(DataFrame(t2)) == hash(df)
# t3 = Taro.readxl(writetestfile,2,"A1:E9")
# @test hash(t3) == hash(df)

# clean up
rm(writetestfile; force=true)

#Test Date Routines
t=Dates.now()
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
write(joinpath(dirname(@__FILE__), "write-tests.xlsx"), w)

#read the file we just wrote
w2=Workbook(joinpath(dirname(@__FILE__), "write-tests.xlsx"))
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
    rm(joinpath(dirname(@__FILE__), "write-tests.xlsx"))
catch
end

@assert !isfile("$(joinpath(tdir,"simple.pdf"))")
Taro.fo(joinpath(tdir, "simple.fo"), joinpath(tdir,"simple.pdf"))
@assert isfile("$(joinpath(tdir,"simple.pdf"))")
JavaCall.destroy()
