using Documenter
using Taro

makedocs(
    modules = [Taro, JavaCall],
    clean = false,
    format = [:html],
    sitename = "Taro",
    authors = "Avik Sengupta",
    assets = ["assets/custom.css"],
    pages = Any[
        "Home" => "index.md",
        "Manual" => Any[
            "Extraction" => "guide/extract.md",
            "Excel" => "guide/hssf.md",
            "XSL-FO" => "guide/fo.md"
        ],
        "API Reference" => "api.md"
    ]
)
