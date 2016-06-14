using Documenter
using Taro

makedocs(;debug=true, root = Pkg.dir("Taro", "docs"), modules = [Taro])
cd(Pkg.dir("Taro", "docs")) do
    run(`mkdocs build --clean`)
end

#mkdocs gh-pages
