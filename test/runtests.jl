using Base.Test
using Taro

Taro.init()

meta, body=Taro.extract("$(joinpath(Pkg.dir(),"Taro","test","WhyJulia.docx"))")
@test length(names(meta)) > 5
@test length(body)>2000


meta, body=Taro.extract("$(joinpath(Pkg.dir(),"Taro","test","WhyJulia.pdf"))")
@test length(names(meta)) > 5
@test length(body)>3000

JavaCall.destroy()
