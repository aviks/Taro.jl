Taro has an interface to the `Apache FOP` project. This allows you to generate professional quality PDF files from `XSL-FO` layout definition templates. Please see the [FOP Documentation](https://xmlgraphics.apache.org/fop/) for details.

The [`Taro.fo`](@ref) function take two parameters: an input FO file name, and an output PDF file name, and creates the latter from the former. The FO file is usually created by injecting dynamic data into a template. 

```@example
using Taro
#Use Mustache.jl to inject content into the template
#stored in tables.fo.tmpl
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

```
