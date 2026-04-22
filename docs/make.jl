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
    ],
)

deploydocs(;
    repo="github.com/cihga39871/AtomicChannels.jl",
    devbranch="main",
)
