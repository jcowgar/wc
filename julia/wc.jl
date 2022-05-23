using Printf

showLines = false
showWords = false
showChars = false

mutable struct Stats
    lines
    words
    chars

    Stats() = new(0, 0, 0)
end

function count_words(fname::String)::Stats
    inWord = false
    s = Stats()

    io = open(fname, "r")

    while !eof(io)
        bytes = read(io, 1024 * 16)

        for b in bytes
            s.chars += 1

            if b == 0x0A
                s.lines += 1
                inWord = false
            elseif b <= 0x20 || b == 0xA0 || b == 0x85
                inWord = false
            elseif !inWord
                inWord = true
                s.words += 1
            end
        end
    end

    close(io)

    return s
end

function report(s, label)
    if showLines
        @printf("%7d", s.lines)
    end
    if showWords
        @printf(" %7d", s.words)
    end
    if showChars
        @printf(" %7d", s.chars)
    end

    @printf(" %s\n", label)
end

total = Stats()
fileCount = 0

for arg in ARGS
    if arg == "-l"
        global showLines = true
        continue
    elseif arg == "-w"
        global showWords = true
        continue
    elseif arg == "-m"
        global showChars = true
        continue
    end

    if showLines == false && showWords == false && showChars == false
        showLines = true
        showWords = true
        showChars = true
    end

    global fileCount += 1
    s = count_words(arg)

    report(s, arg)

    total.lines += s.lines
    total.words += s.words
    total.chars += s.chars
end

if fileCount > 1
    report(total, "total")
end

