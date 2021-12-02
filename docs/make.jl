using AbstractDAQ
using Documenter

DocMeta.setdocmeta!(AbstractDAQ, :DocTestSetup, :(using AbstractDAQ); recursive=true)

makedocs(;
    modules=[AbstractDAQ],
    authors="Paulo Jabardo <pjabardo@ipt.br>",
    repo="https://github.com/pjsjipt/AbstractDAQ.jl/blob/{commit}{path}#{line}",
    sitename="AbstractDAQ.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
