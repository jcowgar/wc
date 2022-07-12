using Printf

include("WordCounter.jl")

mutable struct Options
    files::Vector{String}
    showLines::Bool
    showWords::Bool
    showChars::Bool
end

function parseOptions()::Options
    opts = Options([], false, false, false)

    for arg in ARGS
        if arg == "-l"
            opts.showLines = true
        elseif arg == "-w"
            opts.showWords = true
        elseif arg == "-m"
            opts.showChars = true
        else
            push!(opts.files, arg)
        end
    end

    if opts.showLines == false && opts.showWords == false && opts.showChars == false
        opts.showLines = true
        opts.showWords = true
        opts.showChars = true
    end

    opts
end

function report(opts::Options, stats::WordCounter.Stats, label::String)
    if opts.showLines
        @printf(" %7d", stats.lines)
    end
    if opts.showWords
        @printf(" %7d", stats.words)
    end
    if opts.showChars
        @printf(" %7d", stats.chars)
    end

    @printf(" %s\n", label)
end

function main()
    opts = parseOptions()

    for filename in opts.files
        stats = WordCounter.count(filename)

        report(opts, stats, filename)
    end
end

main()