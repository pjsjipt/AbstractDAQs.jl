using AbstractDAQs
using Documenter

DocMeta.setdocmeta!(AbstractDAQs, :DocTestSetup, :(using AbstractDAQs); recursive=true)

makedocs(;
    modules=[AbstractDAQ],
    authors="Paulo Jabardo <pjabardo@ipt.br>",
    repo="https://github.com/pjsjipt/AbstractDAQs.jl/blob/{commit}{path}#{line}",
    sitename="AbstractDAQs.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
