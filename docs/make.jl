using Documenter
using Taro

makedocs(;debug=true, root = dirname(@__FILE__), modules = [Taro, JavaCall])
cd(dirname(@__FILE__)) do
    run(`mkdocs build --clean`)
end

#mkdocs gh-pages
