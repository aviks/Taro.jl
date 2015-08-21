using Base.Test
using Taro

tdir = joinpath(Pkg.dir("Taro"),"test")
Taro.init()

meta, body=Taro.extract("$(joinpath(tdir,"WhyJulia.docx"))")
@test length(names(meta)) > 5
@test length(body)>2900


meta, body=Taro.extract("$(joinpath(tdir,"WhyJulia.pdf"))")
@test length(names(meta)) > 5
@test length(body)>3000

df=Taro.readxl("$(joinpath(tdir,"df-test.xlsx"))","Sheet1", "B2:F10")
@test 5==length(df)
@test 8==length(df[1])


try 
    rm("$(joinpath(tdir,"simple.pdf"))")
catch
end

@assert !isfile("$(joinpath(tdir,"simple.pdf"))")
Taro.fo(joinpath(tdir, "simple.fo"), joinpath(tdir,"simple.pdf"))
@assert isfile("$(joinpath(tdir,"simple.pdf"))")
JavaCall.destroy()
