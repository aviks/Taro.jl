using Base.Test
using Taro

Taro.init()

meta, body=Taro.extract("$(joinpath(Pkg.dir(),"Taro","test","WhyJulia.docx"))")
@test length(names(meta)) > 5
@test length(body)>2900


meta, body=Taro.extract("$(joinpath(Pkg.dir(),"Taro","test","WhyJulia.pdf"))")
@test length(names(meta)) > 5
@test length(body)>3000

df=Taro.readxl("$(joinpath(Pkg.dir(),"Taro","test","df-test.xlsx"))","Sheet1", "B2:F10")
@test 5==length(df)
@test 8==length(df[1])
JavaCall.destroy()
