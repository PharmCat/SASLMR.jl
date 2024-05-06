using SASLMR
using Documenter

DocMeta.setdocmeta!(SASLMR, :DocTestSetup, :(using SASLMR); recursive=true)

makedocs(;
    modules=[SASLMR],
    authors="Vladimir Arnautov",
    sitename="SASLMR.jl",
    format=Documenter.HTML(;
        canonical="https://PharmCat.github.io/SASLMR.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/PharmCat/SASLMR.jl",
    devbranch="main",
)
