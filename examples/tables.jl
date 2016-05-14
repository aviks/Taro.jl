using Taro
#Use Mustache.jl to inject content into the template
#template stored in tables.fo.tmpl in this directory
using Mustache
#Using Faker to generate fake date for the test
using Faker


tdir = joinpath(Pkg.dir("Taro"),"examples")
#Load template to memory from file
tmpl = Mustache.template_from_file(joinpath(tdir, "tables.fo.tmpl"))

#Generate Fake data
d=Array(Dict, 100);
for i in 1:length(d)
    d[i] = Faker.simple_profile()
end

#Create temporary file to store the rendered fo file
tn, to=mktemp()
#render the mustache template to fo file
#This step injects the dynamic data into the template
fo=render(tmpl, D=d)
write(to, fo )
close(to)

#convert the FO file to PDF
Taro.fo(tn, joinpath(tdir,"tables.pdf"))
