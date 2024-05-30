using WithAlloc
using Documenter

DocMeta.setdocmeta!(WithAlloc, :DocTestSetup, :(using WithAlloc); recursive=true)

makedocs(;
    modules=[WithAlloc],
    authors="Christoph Ortner <christohortner@gmail.com> and contributors",
    sitename="WithAlloc.jl",
    format=Documenter.HTML(;
        canonical="https://ACEsuit.github.io/WithAlloc.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ACEsuit/WithAlloc.jl",
    devbranch="main",
)
