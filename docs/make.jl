using AtomicChannels
using Documenter

DocMeta.setdocmeta!(AtomicChannels, :DocTestSetup, :(using AtomicChannels); recursive=true)

makedocs(;
    modules=[AtomicChannels],
    authors="Dr. Jiacheng Chuan <jiacheng_chuan@outlook.com> and contributors",
    sitename="AtomicChannels.jl",
    format=Documenter.HTML(;
        canonical="https://cihga39871.github.io/AtomicChannels.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "AtomicChannel" => "atomic-channel.md",
        "ReusePool" => "reuse-pool.md",
        "API Reference" => "api.md",
    ],
)
if haskey(ENV, "GITHUB_TOKEN")
    deploydocs(;
        repo="github.com/cihga39871/AtomicChannels.jl",
        devbranch="main",
    )
end
