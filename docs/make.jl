push!(LOAD_PATH, "../src/")

using Documenter, Tabben

makedocs(
    sitename="Tabben.jl Documentation",
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", nothing) == "true"
    ),
    modules=[Tabben],
    pages=[
        "Home" => "index.md"
    ]
)

deploydocs(
    repo = "github.com/TabbenBenchmark/Tabben.jl.git",
    devbranch = "main",
    devurl="latest"
)
